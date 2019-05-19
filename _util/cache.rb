#!/usr/bin/ruby -Ku 
# -*- coding: utf-8 -*-
require 'singleton'
require 'memcache'
require_relative './serializer'
require_relative '../_config/const'

class Cache
include Singleton
attr_reader :client

def initialize
	@@client = MemCache.new(CACHE_ADDRESS + ":" + CACHE_PORT)
end

def get(key)
	cache = @@client.get(key)
	
	if cache.nil?
		return nil
	end
	
	obj = Serializer.load(cache)
	return obj
end

def set(key, obj)
	cache = Serializer.dump(obj)
	@@client.add(key, cache)
end

def self.close
	if defined?(@@client)
		@@client.reset
	end
end

end