#!/usr/bin/env ruby
::ROOT_DIR = File.expand_path(File.dirname(__FILE__)+'/..') unless defined? ::ROOT_DIR
Dir[::ROOT_DIR+'/vendor/**/lib'].each{|dir| $: << dir }
EMR_CONFIG_DIR = ::ROOT_DIR + '/config'
#
require 'rubygems'
require 'wukong'
require 'wukong/script/emr_command'

#
# Takes a graph in adjacency list form (node id followed by id of each out-neighbor):
#
#   node_id: nbr_id nbr_id nbr_id nbr_id
#
# Emits the node_id and its out-degree -- the cound of all its neighbors
#
class AdjacencyListToDegree < Wukong::Streamer::RecordStreamer
  # pull off the first field as the node id, the rest as neighbors.
  def recordize line
    id, *nbrs = line.split(/\W+/)
    [id, nbrs]
  end

  #
  # @param id   a string ID for the node
  # @param nbrs an array of neighbor ids
  #
  def process id, nbrs
    return if id.blank? || nbrs.blank?
    yield [id, nbrs.count, Time.now.to_i]
  end
end

Wukong::Script.new( AdjacencyListToDegree, nil ).run
