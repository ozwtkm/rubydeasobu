#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require_relative '../_util/SQL_master'

class Gacha

def initialize(probability_range)
	
	@probability_range = probability_range

end


def self.get_gacha(gacha_id)

	sql_master = SQL_master.instance.sql
	
	statement = sql_master.prepare("select monster_id, probability from master.gacha_probability where gacha_id = ? order by 'probability' desc")
	result = statement.execute(gacha_id)
	
	probability_range = {}
	count = 0
	result.each do |row|

		row["probability"] += count
		
		probability_range.store(row["monster_id"], row["probability"])
		
		count = row["probability"]

	end

	statement.close

	# lastがsumと一致するのでlast値と満たすべき確率合計値を比較
	if probability_range.values.last != 100000
	
		raise
	
	end

	gacha = Gacha.new(probability_range)

	return gacha

end


# ▽ガチャのアルゴリズム説明
# 　①確率ごとにrangeを設定。
# 　　このとき昇順に並ぶ&確立値が加算されていく。
# 　②確率帯で乱数発行する。
# 　③①のrangeに照合（rand < range_max）していく。
# 　　①は昇順sortedのため、最初にrangeに合致するmonsterを当選とすれば要件を満足する。
def execute_gacha()

	random = SecureRandom.random_number(99999)

	obtain_monster_id = nil
	@probability_range.each do |key, val|
	
		if random < val then
		
			obtain_monster_id = key
			
			break
			
		end
	
	end

	return obtain_monster_id

end


end

