#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

class Gacha

def initialize(probability)
	
	@probability = probability

end


def self.get_gacha(gacha_id, sql)

	statement = sql.prepare("select monster_id, probability from gacha_probability where gacha_id = ? order by 'probability' desc;")
	result_tmp = statement.execute(gacha_id)
	
	result = []
	result_tmp.each do |row|

		result << row
				
	end

	gacha = Gacha.new(sql, result)

	return gacha

end


end





