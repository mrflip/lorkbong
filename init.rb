::ROOT_DIR = File.expand_path(File.dirname(__FILE__)) unless defined? ::ROOT_DIR
URL_BASE = ''

begin
  require "vendor/dependencies/lib/dependencies"
rescue LoadError
  require "dependencies"
end
require "monk/glue"
require "json"
require 'sinatra'
require 'haml'
require 'extlib'
require 'rack/flash'

# Load initializers
Dir[root_path("config/initializers/*.rb")].each{|file| require file.gsub(/\.rb$/, '\1') }
# require 'dm-core'
# require 'dm-validations'
# require 'dm-timestamps'

class Main < Monk::Glue
  set :app_file, __FILE__
  configure :production do
    set :static,           false
  end
  configure :development, :test do
    set :static,           true
    set :clean_trace,      true
  end
  set :logging,          false
  # use Rack::Session::Cookie,
  #   :key          => 'rack.session',
  #   :domain       => settings(:domain),
  #   :path         => '/',
  #   :expire_after => 2592000,
  #   :secret       => settings(:session_secret)
  set :sessions, true
  use Rack::Flash, :accessorize => [:success, :notice, :error]
end

# Load all application files.
Dir[root_path("app/**/*.rb")].each do |file|
  require file
end

# Shim in any rack Middleware
Main.class_eval do
end

# # Connect to database.
# sqlite3_path = settings(:sqlite3)[:database]
# DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/#{sqlite3_path}")

Main.run! if Main.run?
