#!/usr/bin/ruby -Ku 
# -*- coding: utf-8 -*-

require_relative '../exception/Error_unset'

class Log
@@log = nil

def self.set_log(log)
	@@log = log
end

def self.log(o)
	if @@log.nil?
		raise Error_unset.new("log")
	end
	
	@@log.puts(o)
end


end