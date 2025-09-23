require 'net/smtp'
require 'pg'
DB = PG::Connection.new(dbname: 'sivers', user: 'sivers')

SERV = DB.exec("select o.config('smtp_server')")[0]['config']
USER = DB.exec("select o.config('smtp_user')")[0]['config']
PASS = DB.exec("select o.config('smtp_pass')")[0]['config']

def send(email_id)
  msg = DB.exec_params("select msg from o.email_text($1)", [email_id])[0]['msg']
end

def sendall()
  DB.exec("select id from emails where outgoing is null order by id desc").each do |r|
    send(r['id'])
  end
end

