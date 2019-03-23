#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

class Gacha

def initialize(sql)

	@sql = sql

end


def get_probability(gacha_id)

	statement = @sql.prepare("select monster_id, probability from gacha_probability where gacha_id = ? order by 'probability' desc;")
	result_tmp = statement.execute(gacha_id)
	
	result = []
	result_tmp.each do |row|

		result << row
				
	end

	return result

end


end





