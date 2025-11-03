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

# give the PostgreSQL function name, and its parameters
# this will call it and send its result to web(r)
# example:
# web2('myapp.myfunction', id, params['name'])
# ... calls:
# DB.exec_params("select head, body from myapp.myfunction($1, $2)", [id, params['name']])
# ... then gets the first row and sends it to the web(r) function above
def web2(func, *params)
  # creates argument string: "()" or "($1)" or "($1,$2)" etc.
  qs = '(%s)' % (1..params.size).map {|i| "$#{i}"}.join(',')
  sql = "select head, body from #{func}#{qs}"
  r = DB.exec_params(sql, params)[0]
  web(r)
end

