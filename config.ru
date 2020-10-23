require 'rack/protection'
use Rack::Protection # Something is better than nothing! ;]

require "./lib/carstens/butler/main"

$stdout.sync = true # Make sure Heroku logs show up right away

run Sinatra::Application