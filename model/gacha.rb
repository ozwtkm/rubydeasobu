#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

class Gacha

def initialize(probability)
	
	@probability = probability

end


def self.get_gacha(gacha_id, sql)

	statement = sql.prepare("select monster_id, probability from gacha_probability where gacha_id = ? order by 'probability' desc")
	result_tmp = statement.execute(gacha_id)
	
	result = []
	result_tmp.each do |row|

		result << row
				
	end

	probability= []
	result.each do |row|
	
		id = row["monster_id"]
		pro = row["probability"]
	
		probability << {id => pro}
	
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
	
	count = 0
	probability_range = @probability.map do |row|
	
		count += 1
		if count === 1 then
		
			{row.keys[0] => row.values[0]}
			
			next
		
		end
	
		{row.keys[0] => row.values[0] + probability_range[count-1].values[0]}
	
	end
	

	# lastがsumと一致するのでlast値と満たすべき確率合計値を比較
	if probability_range.last.values[0] != 100000
	
		raise
	
	end


	random = SecureRandom.random_number(99999)

	obtain_monster_id = 0
	probability_range.each do |row|
	
		if random < row.values[0] then
		
			obtain_monster_id = row.keys[0]
			
			break
			
		end
	
		i += 1
	
	end

	return obtain_monster_id

end


end





