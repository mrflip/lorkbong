require 'rubygems'
require File.expand_path(File.dirname(__FILE__)+'/../init.rb')

desc 'Make a little gist'
task :gist do
  require 'gist'
  Gist.write(["Hello at", Time.now].join("\t"))
end
