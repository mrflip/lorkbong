# -*- encoding: binary -*-

unless defined? RAILS_GEM_VERSION
  RAILS_GEM_VERSION = ENV['UNICORN_RAILS_VERSION']
end

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.frameworks -= [ :active_resource, :action_mailer ]
  config.action_controller.session_store = :active_record_store
  config.action_controller.session = {
    :session_key => "_unicorn_rails_test.#{rand}",
    :secret => "#{rand}#{rand}#{rand}#{rand}",
  }
end
