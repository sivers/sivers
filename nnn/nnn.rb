# router for nownownow.com/search
require 'sinatra'
require 'pg'
DB ||= PG::Connection.new(dbname: 'sivers', user: 'sivers')

# Sinatra Rack response = Array: [status (Integer), headers (Hash), body]
def web(r)
  status = 200
  headers = {}
  if r['head']
    # headers returned as "\r\n" separated text lines by PostgreSQL
    headlines = r['head'].split("\r\n")
    # if first line is [0-9]{3} set that status
    if /\A[0-9]{3}\Z/ === headlines[0] 
      status = headlines.shift.to_i
    end
    # add or update headers
    headlines.each do |line|
      # proper format separated by ': '
      # example: Location: /home
      k, v = line.split(': ')
      headers[k] = v
    end
  end
  [status, headers, r['body']]
end

get '/search' do
  redirect to('/') if params['q'].nil?
  redirect to('/') if params['q'].size < 3
  redirect to('/') if params['q'].size > 30
  r = DB.exec_params("select head, body from nnn.search($1)",
    [params['q']])[0]
  web(r)
end

