require 'http'
require 'logger'
require 'openssl'
require 'sinatra'
require 'time'
require "pry" if development? || test?
require "sinatra/reloader" if development?

configure :development do
  set :logging, Logger::DEBUG
end

set :bind, '0.0.0.0'

get '/' do
  'Hello world!'
end

def carsten_bot(question)
  question ||= ""
  question.downcase!
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

post '/ask' do
  logger.debug "Headers: #{headers}"
  logger.debug "request.env: #{request.env}"
  etag '', :new_resource => true
  request.body.rewind
  data = JSON.parse request.body.read
  question = data.first[1].downcase
  logger.debug question
  carsten_bot(question)
end

post '/slack/challenge' do
  logger.debug "headers: #{headers}"
  logger.debug "request.env: #{request.env}"
  etag '', :new_resource => true
  request.body.rewind
  raw_body = request.body.read
  data = JSON.parse raw_body
  challenge = data['challenge']
  logger.debug "raw_body: #{raw_body}"
  logger.debug "data: #{data}"
  logger.debug "challenge: #{challenge}"


  timestamp = request.env['HTTP_X_SLACK_REQUEST_TIMESTAMP']
  logger.debug "timestamp: #{timestamp}"
  # The request timestamp is more than five minutes from local time.
  # It could be a replay attack, so let's ignore it.
  limit = ENV["RACK_ENV"] == "production" ? 5 : 600
  if (Time.now.to_i - timestamp.to_i).abs > 60 * limit
    logger.debug "Old request, ignoring!"
    return
  end
  basestring = ['v0', timestamp, raw_body].join(':')
  keys = ENV['SLACK_SIGNING_SECRETS'].split(',')
  digest = OpenSSL::Digest.new('sha256')
  hmac = nil
  keys.each_with_index do |key, i|
    hmac = "v0=#{OpenSSL::HMAC.hexdigest(digest, key, basestring)}"
    slack_signature = request.env['HTTP_X_SLACK_SIGNATURE']
    if hmac == slack_signature
      logger.debug "hooray, the request came from Slack!"
      return deal_with_request(data, challenge)
    else
      logger.debug "Failed key #{i}"
    end
  end
  [401, "Invalid request, X-Slack-Signature: #{request.env['HTTP_X_SLACK_SIGNATURE']}, hmac: #{hmac}"]
end

def deal_with_request(data, challenge)
  logger.debug "data: #{data}"
  logger.debug "challenge: #{challenge}"
  return challenge if challenge
  return if data.dig("event", "subtype") == "bot_message" # Don't reply to bots, this sends you into a loop of talking to yourself! ;]
  post_url = ENV['POST_WEBHOOK_URL']
  reply = carsten_bot(data.dig("event", "text"))
  if ENV["RACK_ENV"] == "production"
    HTTP.post(post_url, :body => {"text" => reply}.to_json)
  else
    reply
  end
end
