#!/usr/bin/ruby -Ku 
# -*- coding: utf-8 -*-
require_relative '../exception/Error_input_nil'
require_relative '../exception/Error_input_specialcharacter'
require_relative '../exception/Error_not_found'
require_relative '../exception/Error_over_count'
require_relative '../exception/Error_not_naturalnumber'

class Validator

def self.validate_nil(key, value)
		if value.nil?
			raise Error_input_nil.new(key)
		end
end


def self.validate_special_character(key, value)
		if value.match(/\A[a-zA-Z0-9_@]+\z/).nil?
			raise Error_input_special_character.new(key)
		end
end

def self.validate_SQL_error(record_count, is_multi_line: false)

	if record_count === 0
		raise Error_not_found.new
	end

	if is_multi_line
		return
	end
	
	if record_count != 1
		raise Error_over_count.new
	end
	
end

def self.validate_not_Naturalnumber(key, value)
	if value.match(/\A[0-9]+\z/).nil?
		raise Error_not_naturalnumber.new(key)
	end
end


end