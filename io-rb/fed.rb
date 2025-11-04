# ActivityPub server: only JSON in and out
require 'rack'
require 'json'
require 'pg'
DB ||= PG::Connection.new(dbname: 'sivers', user: 'sivers')

# Rack response = Array: [status (Integer), headers (Hash), [body]]
# these two functions same as web and web2 but for JSON
def jres(r)
  status = 200
  headers = {'content-type' => 'application/activity+json; charset=utf-8'}
  if r['head']
    headlines = r['head'].split("\r\n")
    if /\A[0-9]{3}\Z/ === headlines[0] 
      status = headlines.shift.to_i
    end
    headlines.each do |line|
      k, v = line.split(': ')
      headers[k.downcase] = v
    end
  end
  [status, headers, [r['body'] || '']]
end

def j2(func, *params)
  qs = '(%s)' % (1..params.size).map {|i| "$#{i}"}.join(',')
  sql = "select head, body from #{func}#{qs}"
  r = DB.exec_params(sql, params)[0]
  jres(r)
end

class Fed
  def call(env)
    q = Rack::Request.new(env)
    unless ['application/activity+json', 'application/ld+json', 'application/json'].include?(q.media_type)
      return [415, {'content-type' => 'text/plain'}, ['content-type must be json']]
    end
    begin
      js = JSON.parse(q.body.read)
    rescue JSON::ParserError
      return [400, {'content-type' => 'text/plain'}, ['bad json, bad!']]
    end

    if q.post? && q.path_info == '/d/inbox'
      jres({'head' => '202', 'body' => '{"ind":true}'})
    else
      jres({'head' => '404', 'body' => '{"found":false}'})
    end
  end
end

