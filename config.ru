require "./lib/carstens/butler/main"
require 'rack/protection'
use Rack::Protection # Something is better than nothing! ;]

$stdout.sync = true # Make sure Heroku logs show up right away

run Sinatra::Application