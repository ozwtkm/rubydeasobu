#!/usr/bin/ruby -Ku 
# -*- coding: utf-8 -*-

require_relative '../exception/Error_input_nil'
require_relative '../exception/Error_input_specialcharacter'
require_relative '../exception/Error_not_found'


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


def self.validate_SQL_error(target, record_count = 0)

	if target == record_count

		raise Error_not_found.new

	end

end

end
