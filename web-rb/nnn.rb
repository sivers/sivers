# router for nownownow.com/search
require 'rack'
require 'pg'
DB ||= PG::Connection.new(dbname: 'sivers', user: 'sivers')
require_relative 'web.rb'

class NNN
  def call(env)
    q = Rack::Request.new(env)

    if q.get? && q.path_info == '/random'
      r = DB.exec("select head from nnn.random()")[0]
      web(r)

    elsif q.get? && q.path_info == '/search' &&
      q.params['q'] &&
      q.params['q'].size > 2 &&
      q.params['q'].size < 30
      r = DB.exec("select head, body from nnn.search($1)", [q.params['q']])[0]
      web(r)

    else
      web({'head' => "303\r\nLocation: /"})

    end
  end
end

