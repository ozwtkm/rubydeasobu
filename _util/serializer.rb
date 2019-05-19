#!/usr/bin/ruby -Ku 
# -*- coding: utf-8 -*-
require 'base64'

class Serializer

def self.dump(obj)
	obj = Marshal.dump(obj)
	result = Base64.urlsafe_encode64(obj)
	
	return result
end

def self.load(str)
	str = Base64.urlsafe_decode64(str)
	result = Marshal.load(str)

	return result
end

end