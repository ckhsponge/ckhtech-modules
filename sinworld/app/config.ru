require 'rack'
require 'rack/contrib'

require "#{File.dirname(__FILE__)}/application"

# require_relative './app'

require 'rack/contrib/post_body_content_type_parser'

use Rack::JSONBodyParser

set :root, File.dirname(__FILE__)
# set :views, Proc.new { File.join(root, "views") }

run Sinatra::Application

