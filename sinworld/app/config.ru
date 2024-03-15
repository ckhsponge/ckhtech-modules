
require "#{File.dirname(__FILE__)}/application"

use Rack::JSONBodyParser

# run Sinatra::Application
# map( "/sessions" ) { run SessionsController }
# map( "/pages" ) { run PagesController }
# map( "/imager" ) { run ImagesController }
# map( "/users" ) { run UsersController }
# map( "/payments" ) { run PaymentsController }
# map( "/tests" ) { run TestsController }
map( "/" ) { run RootController }
