require 'rubygems'
::ROOT_DIR = File.expand_path(File.dirname(__FILE__)) unless defined?(::ROOT_DIR)
require ::ROOT_DIR+'/init.rb'
Dir[::ROOT_DIR+'/tasks/*.rake'].sort.each{|task_file| load(task_file) }

desc 'Default task: run all tests'
task :default => [:test]

task :test do
  exec "thor monk:test"
end
