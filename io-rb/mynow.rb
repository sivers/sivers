# router for my.nownownow.com
require_relative '../email.rb'
require_relative 'web.rb'
require 'net/ftp'
require 'net/http'
require 'uri'
require 'json'

WEBPDIR = '/var/www/html/nownownow.com/m/'
CDNHOST = DB.exec("select o.config('cdn-nnn-host')")[0]['config']
CDNUSER = DB.exec("select o.config('cdn-nnn-user')")[0]['config']
CDNPASS = DB.exec("select o.config('cdn-nnn-pass')")[0]['config']
CDNAPIK = DB.exec("select o.config('cdn-api-key')")[0]['config']

class MyNow
  def call(env)
    q = Rack::Request.new(env)

# GET /f
# ask email address or show message (?m=code) about form
    if q.get? && q.path_info == '/f'
      r = DB.exec("select head, body from mynow.authform($1, $2)",
        [ q.cookies['ok'], q.params['m'] ])[0]
      web(r)

# POST /f
# receive email address from GET /f form
# email templink then redirect to /f?m=_ message
    elsif q.post? && q.path_info == '/f'
      r = DB.exec("select head, body from mynow.authpost($1, $2)",
        [ q.cookies['ok'], q.params['email'] ])[0]
      if r['head'].nil?  # means no errors
        Thread.new { sendemails }
      end
      web(r)

# GET /e
# clicked link from emailed templink always /e?t={tempcode}
# if cookie already set, redirect to /
# if tempcode found in DB, get id and person name
# show page either "not found" or form post login, posting tempcode and id#
    elsif q.get? && q.path_info == '/e'
      r = DB.exec("select head, body from mynow.welcome($1, $2)",
        [ q.cookies['ok'], q.params['t'] ])[0]
      web(r)

# POST /e
# temp_use: if tempcode and id match, use id to set cookie and delete tempcode
# set cookie and redirect to / (if it was wrong, / will send back to auth)
    elsif q.post? && q.path_info == '/e'
      r = DB.exec("select head, body from mynow.login($1, $2)",
        [ q.params['t'], q.params['i'] ])[0]
      web(r)

# GET /z
# delete cookie and show "logged out" message
    elsif q.get? && q.path_info == '/z'
      r = DB.exec("select head, body from mynow.logout($1)",
        [ q.cookies['ok'] ])[0]
      web(r)

# GET /
# home page asks their location
    elsif q.get? && q.path_info == '/'
      r = DB.exec("select head, body from mynow.whereru($1)",
        [ q.cookies['ok'] ])[0]
      web(r)

# POST /where
# update their city/state/country
# redirect to /urls if successful or GET / if not
    elsif q.post? && q.path_info == '/where'
      r = DB.exec("select head, body from mynow.whereset($1, $2, $3, $4)",
        [ q.cookies['ok'],
          q.params['city'],
          q.params['state'],
          q.params['country'] ])[0]
      web(r)

# GET /urls
# form to add their URLs or, when done, link to GET /photo
    elsif q.get? && q.path_info == '/urls'
      r = DB.exec("select head, body from mynow.urls($1)",
        [ q.cookies['ok'] ])[0]
      web(r)

# POST /urls
# add their URL and redirect to /urls for more
    elsif q.post? && q.path_info == '/urls'
      r = DB.exec("select head, body from mynow.urladd($1, $2)",
        [ q.cookies['ok'], q.params['url'] ])[0]
      web(r)

# POST /urls/main/[0-9]+
# set this URL as their main one and redirect to /urls
    elsif q.post? &&
      (m = %r{\A/url/([1-9][0-9]*)/main\z}.match(q.path_info))
      r = DB.exec("select head, body from mynow.urlmain($1, $2)",
        [ q.cookies['ok'], m[1].to_i ])[0]
      web(r)

# POST /urls/delete/[0-9]+
# delete this URL and redirect to /urls
    elsif q.post? &&
      (m = %r{\A/url/([1-9][0-9]*)/delete\z}.match(q.path_info))
      r = DB.exec("select head, body from mynow.urldel($1, $2)",
        [ q.cookies['ok'], m[1].to_i ])[0]
      web(r)

# GET /photo
# form to upload photo, and show uploaded 
# when done, link to GET /profile
    elsif q.get? && q.path_info == '/photo'
      r = DB.exec("select head, body from mynow.photo($1)",
        [ q.cookies['ok'] ])[0]
      web(r)

# POST /photo
# receive uploaded photo: update now_profiles set photo=true
# if they uploaded photo, new name is public_id.webp
# vips copy #{tempfile} #{webp}[Q=100,strip]
# save to local path for display
# upload to CDN in background
# redirect to /photo
    elsif q.post? && q.path_info == '/photo'
      photo = q.params["photo"] || q.params[:photo]
      web({'head' => "303\r\nLocation: /photo"}) unless photo && photo[:tempfile]
      tempfile = photo[:tempfile].path
      web({'head' => "303\r\nLocation: /photo"}) unless File.exist?(tempfile)
      r = DB.exec("select code from mynow.photoset($1)", [q.cookies['ok']])[0]
      webp = WEBPDIR + r['code'] + '.webp'
      system("vips copy #{tempfile} #{webp}[Q=100,strip]")
      if File.exist?(webp)
        Thread.new(webp) do |img| # make variable local to thread to be safe
          begin
            ftp = Net::FTP.new(CDNHOST)
            ftp.passive = true
            ftp.login(CDNUSER, CDNPASS)
            ftp.putbinaryfile(img)
            ftp.close
            url = URI.parse('https://api.bunny.net/purge?url=https%3A%2F%2Fm.nownownow.com%2F' + img.gsub(WEBPDIR, ''))
            req = Net::HTTP::Post.new(url)
            req['AccessKey'] = CDNAPIK
            Net::HTTP.start(url.host, url.port, use_ssl: true) do |http|
              http.request(req)
            end
          rescue
            # oh well
          end
        end
      end
      web({'head' => "303\r\nLocation: /photo"})

# GET /profile
# form to ask the five profile questions
# when done, say thanks, that's the end
# ?edit1=title|liner|why|thought|red when complete to go back and edit one
# passing its null value - when not requested - is expected
    elsif q.get? && q.path_info == '/profile'
      r = DB.exec("select head, body from mynow.profile($1, $2)",
        [ q.cookies['ok'], q.params['edit1'] ])[0]
      web(r)

# POST /profile
# update the five profile questions
# redirect back to GET /profile
    elsif q.post? && q.path_info == '/profile'
      r = DB.exec("select head, body from mynow.profileset($1, $2, $3)",
        [ q.cookies['ok'], q.params['qcode'], q.params['answer'] ])[0]
      web(r)

########### SITE CHECKER:

# POST /check/12/nodate || /check/12/old || /check/12/good || /check/12/gone
# done checking: update meta-info, send formletter, redirect to next check
    elsif q.post? &&
      (m = %r{\A/check/([1-9][0-9]*)/(nodate|old|good|gone)\z}.match(q.path_info))
      r = DB.exec("select head, body from nowx.done($1, $2, $3)",
        [ q.cookies['ok'], m[1], m[2] ])[0]
      web(r)

# POST /check/123 with params[look4] and params[updated_at] in YYYY-MM-DD
    elsif q.post? &&
      (m = %r{\A/check/([1-9][0-9]*)\z}.match(q.path_info))
      && q.params['look4']
      && q.params['updated_at']
      && /2[0-9]{3}-[0-9]{2}-[0-9]{2}/ === q.params['updated_at']
      r = DB.exec("select head, body from nowx.checkupdate($1, $2, $3, $4)",
        [ q.cookies['ok'], m[1], q.params['look4'], q.params['updated_at'] ])[0]
      web(r)

# GET /check/123 - form to check that site
    elsif q.get? &&
      (m = %r{\A/check/([1-9][0-9]*)\z}.match(q.path_info))
      r = DB.exec("select head, body from nowx.one($1, $2)",
        [ q.cookies['ok'], m[1] ])[0]
      web(r)

# GET /check - redirects to next /check/123
    elsif q.get? && q.path_info == '/check'
      r = DB.exec("select head, body from nowx.next($1)",
        [ q.cookies['ok'] ])[0]
      web(r)

    else
      web({'head' => '404', 'body' => '?'})

    end
  end
end

