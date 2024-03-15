require 'rack'
require 'rack/contrib'
require 'rack/contrib/post_body_content_type_parser'

# require 'sinatra' # classic
require 'sinatra/base' # modular
require "sinatra/namespace"
require "sinatra/json"
# require 'sinatra/ratpack'
# require 'sinatra/assets/helpers'
require "dotenv" if Sinatra::Base.development?
require 'json'
# require 'haml'
require 'securerandom'
require 'digest'

# gems from github go in the bundler directory
load_paths = Dir['./vendor/bundle/ruby/**/bundler/gems/**/lib']
$LOAD_PATH.unshift(*load_paths)

APP_ROOT = File.dirname(__FILE__)

def development?
  Sinatra::Base.development?
end

Dotenv.load('../.env') if development?

class BaseController < Sinatra::Application
  def development?
    Sinatra::Base.development?
  end
  set :root, APP_ROOT
  set :views, Proc.new { File.join(root, "views") }
  set :asset_manifest_path, "#{development? ? APP_ROOT + '/../build' : APP_ROOT}/asset-manifest.json"

  use Rack::Session::Cookie,
      :key => 'rack.session',
      # :httponly     => true,
      # :same_site    => :none,
      # :secure       => true,
      # domain: ".#{HOST_BASE}", # session available to all subdomains
      #:path => '/',
      expire_after: 2592000*12*5, # 5 years
      secret:  ENV.fetch('SESSION_SECRET') { SecureRandom.hex(64) }

  set :public_folder, APP_ROOT + '/public'
  set :port, (ENV['RACK_ENV'] == 'production' ? 80 : 9292)

  # before do
  #   if (request.env['HTTP_HOST'] || '').split(':').first == host_base
  #     redirect to(home_url)
  #     halt
  #   end
  # end

  before do
    cache_control "no-cache, no-store, private", max_age: 0
  end
end


class RootController < BaseController
  get '/' do
    "Hello, Sinworld!"
  end
end
