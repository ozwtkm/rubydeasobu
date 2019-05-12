#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

class Pager

def self.paging(data, offset, number=10)
	result = []

	case data.class.to_s
	when "Hash" then
		data.each.with_index do |key,val,index|
			if offset <= index && index < offset+number
				result.store(key,val)
			end
		end
	when "Array" then
		data.each.with_index do |row,index|
			if offset <= index && index < offset+number
				result << row
			end
		end
	end

	return result
end

end

