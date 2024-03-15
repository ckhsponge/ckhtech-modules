require 'rack'
require 'rack/contrib'

require 'sinatra' # classic

get '/' do
  "Hello, Sinworld!"
end
