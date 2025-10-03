#!/usr/bin/env ruby
require 'net/smtp'
require 'pg'
DB ||= PG::Connection.new(dbname: 'sivers', user: 'sivers')

SMTPHOST = DB.exec("select o.config('smtp_server')")[0]['config']
SMTPUSER = DB.exec("select o.config('smtp_user')")[0]['config']
SMTPPASS = DB.exec("select o.config('smtp_pass')")[0]['config']

def sendemail(id)
  r = DB.exec_params("select mailfrom, rcptto, msg from o.emailsmtp($1)", [id])[0]
  return if r['msg'].nil?
  begin
    Net::SMTP.start(SMTPHOST, 587, SMTPHOST, SMTPUSER, SMTPPASS, :login) do |smtp|
      smtp.send_message r['msg'], r['mailfrom'], r['rcptto']
    end
    DB.exec_params("select o.emailsent($1)", [id])
  rescue => err
    # it'll try again since not marked as sent
  end
end

# why newest first? because this is called by login link sender after inserting
def sendemails
  DB.exec("select id from emails where outgoing is null order by id desc").each do |r|
    sendemail(r['id'])
  end
end

if __FILE__ == $PROGRAM_NAME
  sendemails
end
