require 'rack'
require 'rack/contrib'
require_relative 'server'

if Rack::Utils.respond_to?("key_space_limit=")
  Rack::Utils.key_space_limit = 68719476736
end

set :root, File.dirname(__FILE__)

run Sinatra::Application