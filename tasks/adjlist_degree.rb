#!/usr/bin/env ruby
::ROOT_DIR = File.expand_path(File.dirname(__FILE__)+'/..') unless defined? ::ROOT_DIR
Dir[::ROOT_DIR+'/vendor/**/lib'].each{|dir| p dir ; $: << dir }
EMR_CONFIG_DIR = ::ROOT_DIR + '/config'
p $:
#
require 'rubygems'
require 'wukong'
require 'wukong/script/emr_command'

class AdjacencyListToDegree < Wukong::Streamer::RecordStreamer

  def recordize line
    id, nbrs = line.split(/\W+/, 2)
    [id, nbrs]
  end

  def process id, nbrs
    return if id.blank? || nbrs.blank?
    yield [id, nbrs.split(/\W+/).count]
  end
end

class IdentityReducer < Wukong::Streamer::LineStreamer
  def process *args
    yield *args
  end
end

# Settings[:emr_extra_args] = ["--arg '-D mapred.reduce.tasks=0'"]
Wukong::Script.new(
  AdjacencyListToDegree, IdentityReducer,
  :reduce_tasks => 0, :reuse_jvms => true, :partition_fields => 1, :sort_fields => 2
  ).run
