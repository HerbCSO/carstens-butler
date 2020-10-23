require 'sinatra'
require "pry" if development? || test?
require "sinatra/reloader" if development?
set :bind, '0.0.0.0'

get '/' do
  'Hello world!'
end

post '/ask' do
  etag '', :new_resource => true
  request.body.rewind
  data = JSON.parse request.body.read
  question = data.first[1].downcase
  puts question

  bad_clients = ["ngma","cms","tru"]
  probably_no = ["is it possible to","do you think we can","the client asked if we could","is it feasible to","can we","should we","can i","should i"]
  if bad_clients.any? { |client| question.include? client }
    "Yeah, that was really messed up"
  elsif probably_no.any? { |nope| question.include? nope }
    ["That's a really bad idea","Absolutely not!","No, no, no"].sample
  elsif question.include? "nice t-shirt"
    "Thanks"
  elsif question.include? "sneeze"
    "Gesundheit!"
  elsif question.include? "quick question"
    "Is it really going to be quick?"
  else
    ";]"
  end
end
