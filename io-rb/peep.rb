# router for peeps
require_relative 'web.rb'

class Peep
  def call(env)
    q = Rack::Request.new(env)
    kk = q.cookies['ok']

    if kk.nil? && q.path_info != '/login'
      web({'head' => "303\r\nLocation: /login"})

    elsif q.get? && q.path_info == '/login'
      web2('peep.loginform')

    elsif q.post? && q.path_info == '/login'
      web2('peep.login', q.params['email'], q.params['password'])

    elsif q.get? && q.path_info == '/'
      web2('peep.home')

    elsif q.get? && (m = %r{\A/next/([^\s\/]+)\z}.match(q.path_info))
      web2('peep.email_open_next', kk, m[1])

    elsif q.get? && (m = %r{\A/list/([^\s\/]+)\z}.match(q.path_info))
      web2('peep.emails_unopened', m[1])

    elsif q.get? && (m = %r{\A/email/([1-9][0-9]*)\z}.match(q.path_info))
      web2('peep.email_view', kk, m[1])

    else
      web({'head' => "303\r\nLocation: /"})

    end
  end
end

