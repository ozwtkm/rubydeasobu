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
	@@client = Mongo::Client.new(['127.0.0.1:27017'], database: 'ruby_quest_monsters')#todo constに引越し
end


def self.close
	if defined?(@@client)
		@@client.close
	end
end

end