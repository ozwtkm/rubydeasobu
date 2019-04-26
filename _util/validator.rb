#!/usr/bin/ruby -Ku 
# -*- coding: utf-8 -*-

require_relative '../exception/Error_input_nil'
require_relative '../exception/Error_input_specialcharacter'

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


end




