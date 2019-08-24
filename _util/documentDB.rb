#!/usr/bin/ruby -Ku 
# -*- coding: utf-8 -*-
require 'singleton'
require 'mongo'
require 'json'
require_relative '../_config/const'

class DocumentDB
include Singleton
attr_reader :client

def initialize
	address = Environment.documentdb_address()
	port = Environment.documentdb_port()

	@@client = Mongo::Client.new([address + ':' + port], database: 'ruby_quest_monsters')#todo constに引越し
end

def client
	return @@client
end

def self.close
	if defined?(@@client)
		@@client.close
	end
end

end