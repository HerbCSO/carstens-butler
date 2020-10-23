require 'openssl'
require 'sinatra'
require 'time'
require "pry" if development? || test?
require "sinatra/reloader" if development?
set :bind, '0.0.0.0'

get '/' do
  'Hello world!'
end

post '/ask' do
  puts "Headers: #{headers}"
  puts "request.env: #{request.env}"
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

post '/slack/challenge' do
  puts "headers: #{headers}"
  puts "request.env: #{request.env}"
  etag '', :new_resource => true
  request.body.rewind
  raw_body = request.body.read
  data = JSON.parse raw_body
  challenge = data['challenge']
  puts "raw_body: #{raw_body}"
  puts "data: #{data}"
  puts "challenge: #{challenge}"


  timestamp = request.env['HTTP_X_SLACK_REQUEST_TIMESTAMP']
  puts "timestamp: #{timestamp}"
  # The request timestamp is more than five minutes from local time.
  # It could be a replay attack, so let's ignore it.
  if (Time.now.to_i - timestamp.to_i).abs > 60 * 5
    puts "Old request, ignoring!"
    return
  end
  basestring = ['v0', timestamp, raw_body].join(':')
  keys = ENV['SLACK_SIGNING_SECRETS'].split(',')
  digest = OpenSSL::Digest.new('sha256')
  keys.each do |key|
    hmac = "v0=#{OpenSSL::HMAC.hexdigest(digest, key, basestring)}"
    slack_signature = request.env['HTTP_X_SLACK_SIGNATURE']
    if hmac == slack_signature
      puts "hooray, the request came from Slack!"
      deal_with_request(request, challenge)
      return
    end
  end
  [401, "Invalid request, X-Slack-Signature: #{request.env['HTTP_X_SLACK_SIGNATURE']}, hmac: #{hmac}"]
end

def deal_with_request(request, challenge)
  puts "Yay!"
  puts "request: #{request}"
  puts "challenge: #{challenge}"
  challenge
end