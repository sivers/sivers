# router for nownownow.com/search
require_relative 'web.rb'

class NNN
  def call(env)
    q = Rack::Request.new(env)

    if q.get? && q.path_info == '/random'
      web2('nnn.random')

    elsif q.get? && q.path_info == '/search' &&
      q.params['q'] &&
      q.params['q'].size > 2 &&
      q.params['q'].size < 30
      web2('nnn.search', q.params['q'])

    else
      web({'head' => "303\r\nLocation: /"})

    end
  end
end

