#!/usr/bin/env ruby  # static HTML comments, by Derek Sivers. Article: https://sive.rs/shc

require 'pg'
require 'sinatra'
DB = PG::Connection.new(dbname: 'test', user: 'tester')

post '/comments' do
  DB.exec_params("insert into comments
    (uri, name, email, comment)
    values ($1, $2, $3, $4)",
    [params[:uri], params[:name], params[:email], params[:comment]])
  redirect to(request.env['HTTP_REFERER'])
end
