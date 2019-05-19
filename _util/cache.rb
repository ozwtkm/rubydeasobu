#!/usr/bin/ruby -Ku 
# -*- coding: utf-8 -*-
require 'singleton'
require_relative './serializer'

class Cache
include Singleton
attr_reader :client

def initialize
	@client = MemCache.new('localhost:11211')
end

def get(key)
	cache = @client.get(key)
	if cache.nil?
		return nil
	end
	obj = Serializer.load(cache)
	return obj
end

def set(key, obj)
	cache = Serializer.dump(obj)
	@client.add(key, cache)
end

def close

end

end