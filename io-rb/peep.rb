# router for peeps
require_relative 'web.rb'

class Peep
  def call(env)
    q = Rack::Request.new(env)
    kk = q.cookies['ok']

    if kk.nil? && q.path_info != '/login'
      web({'head' => "303\r\nLocation: /login"})

    elsif q.get? && q.path_info == '/login'
      r = DB.exec("select head, body from peep.loginform()")[0]
      web(r)

    elsif q.post? && q.path_info == '/login'
      r = DB.exec("select head, body from peep.login($1, $2)",
        [ q.params['email'], q.params['password'] ])[0]
      web(r)

    elsif q.get? && q.path_info == '/'
      r = DB.exec("select head, body from peep.home()")[0]
      web(r)

    elsif q.get? &&
      (m = %r{\A/next/([^\s\/]+)\z}.match(q.path_info))
      r = DB.exec("select head, body from peep.email_open_next($1, $2)",
        [ kk, m[1] ])[0]
      web(r)

    elsif q.get? &&
      (m = %r{\A/list/([^\s\/]+)\z}.match(q.path_info))
      r = DB.exec("select head, body from peep.emails_unopened($1)",
        [ m[1] ])[0]
      web(r)

    elsif q.get? &&
      (m = %r{\A/email/([1-9][0-9]*)\z}.match(q.path_info))
      r = DB.exec("select head, body from peep.email_view($1)",
        [ m[1] ])[0]
      web(r)

    else
      web({'head' => "303\r\nLocation: /"})

    end
  end
end

