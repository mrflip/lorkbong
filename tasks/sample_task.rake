::ROOT_DIR = File.expand_path(File.dirname(__FILE__)+'/..') unless defined?(::ROOT_DIR)
require 'rubygems'

namespace :emr do
  desc 'Make a little gist'
  task :run do
    require ::ROOT_DIR+'/app/helpers/emr_script'
    sh EmrScript.run_step_command
  end
end
