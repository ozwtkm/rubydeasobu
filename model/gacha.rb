#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require_relative '../_util/SQL_master'

class Gacha

def initialize(probability)
	
	@probability = probability

end


def self.get_gacha(gacha_id)

	sql_master = SQL_master.instance.sql
	
	statement = sql_master.prepare("select monster_id, probability from master.gacha_probability where gacha_id = ? order by 'probability' desc")
	result_tmp = statement.execute(gacha_id)
	statement.close
	
	result = []
	result_tmp.each do |row|

		result << row
				
	end

	probability= {}
	result.each do |row|
	
		id = row["monster_id"]
		pro = row["probability"]
	
		probability.store(id, pro)
	
	end

	gacha = Gacha.new(probability)

	return gacha

end


# ▽ガチャのアルゴリズム説明
# 　①確率ごとにrangeを設定。
# 　　このとき昇順に並ぶ&確立値が加算されていく。
# 　②確率帯で乱数発行する。
# 　③①のrangeに照合（rand < range_max）していく。
# 　　①は昇順sortedのため、最初にrangeに合致するmonsterを当選とすれば要件を満足する。
def execute_gacha()
	
	probability_range = {}
	range_tmp = 0 
	@probability.each do |key,val|
		
		val += range_tmp
		
		probability_range.store(key, val)
		
		range_tmp = val
	
	end

	# lastがsumと一致するのでlast値と満たすべき確率合計値を比較
	if probability_range.values.last != 100000
	
		raise
	
	end

	random = SecureRandom.random_number(99999)

	obtain_monster_id = 0
	probability_range.each do |key, val|
	
		if random < val then
		
			obtain_monster_id = key
			
			break
			
		end
	
	end

	return obtain_monster_id

end


end





