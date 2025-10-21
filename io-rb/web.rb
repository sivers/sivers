require 'rack'
require 'pg'
DB ||= PG::Connection.new(dbname: 'sivers', user: 'sivers')

# Rack response = Array: [status (Integer), headers (Hash), [body]]
def web(r)
  status = 200
  headers = {'content-type' => 'text/html;charset=utf-8'}
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
      headers[k.downcase] = v
    end
  end
  [status, headers, [r['body'] || '']]
end

