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

	probability= {}
	result.each do |row|
	
		id = row["monster_id"]
		pro = row["probability"]
	
		probability.store(id, pro)
	
	end

	gacha = Gacha.new(probability)

	return gacha

end


# 髫ｨ���ｽ�ｽ驛｢�ｧ��ｬ驛｢譏ｶ���取���ｸ�ｺ��ｮ驛｢�ｧ��｢驛｢譎｢�ｽ�ｫ驛｢�ｧ��ｴ驛｢譎｢�ｽ�ｪ驛｢�ｧ��ｺ驛｢謫帝ｫｫ�ｱ��ｬ髫ｴ蠎ｶ
# 驍ｵ�ｲ�驕ｶ�ｭ�鬩墓慣�ｽ�ｺ鬩阪寒閭･�ｼ���ｸ�ｺ��ｨ驍ｵ�ｺ��ｫrange驛｢�ｧ陞ｳ螟ｲ�ｽ�ｨ��ｭ髯橸ｽｳ陞｢�ｹ��
# 驍ｵ�ｲ�驍ｵ�ｲ�驍ｵ�ｺ髦ｮ蜃ｵ�ｮ驍ｵ�ｺ��ｨ驍ｵ�ｺ髢ｧ�ｴ��鬯ｯ��閨ｹ��髣包ｽｳ��ｦ驍ｵ�ｺ��ｶ&鬩墓慣�ｽ�ｺ鬩包ｽｶ陷ｿ�･���､驍ｵ�ｺ隰疲ｺｷ��鬩阪ｇ蟷ｲ＆��ｹ�ｧ陟募ｨｯ��ｻ驍ｵ�ｺ����･驍ｵ�ｲ�
# 驍ｵ�ｲ�驕ｶ�ｭ��｡鬩墓慣�ｽ�ｺ鬩阪寒隘��ｽｽ�ｸ��ｯ驍ｵ�ｺ��ｧ髣包ｽｵ��ｱ髫ｰ�ｨ��ｰ鬨ｾ蜈ｷ�ｽ�ｺ鬮ｯ�ｦ陟募ｨｯ��驛｢�ｧ闕ｵ謐ｩ�
# 驍ｵ�ｲ�驕ｶ�ｭ��｢驕ｶ�ｭ�驍ｵ�ｺ��ｮrange驍ｵ�ｺ��ｫ髴趣ｽ｣��ｧ髯ｷ�ｷ髣鯉ｽｨ��ｼ�rand < range_max�陝ｲ�ｨ＠驍ｵ�ｺ��ｦ驍ｵ�ｺ����･驍ｵ�ｲ�
# 驍ｵ�ｲ�驍ｵ�ｲ�驕ｶ�ｭ�驍ｵ�ｺ��ｯ髫ｴ鬆��ｬ��sorted驍ｵ�ｺ��ｮ驍ｵ�ｺ雋��∞�ｽ竏ｫ�ｸ�ｲ遶擾ｽｵ隲､蜻ｵ蟠戊ｭ擾ｽｴ遶企�蚤nge驍ｵ�ｺ��ｫ髯ｷ�ｷ鬩帚���ｴ驍ｵ�ｺ陷ｷ�ｶ�遐ｧonster驛｢�ｧ髮区ｩｸ�ｽ�ｽ鬯･�ｴ遶剰ご�ｸ�ｺ��ｨ驍ｵ�ｺ陷ｷ�ｶ�讙趣ｽｸ�ｺ��ｰ鬮ｫ陬懈����ｻ��ｶ驛｢�ｧ陷ｻ闌ｨ�ｽ�ｺ�鬮ｮ諛ｶ�ｽ�ｳ驍ｵ�ｺ陷ｷ�ｶ�迢暦ｽｸ�ｲ�
def execute_gacha()
	
	probability_range = {}
	range_tmp = 0 
	@probability.each do |key,val|
		
		val += range_tmp
		
		probability_range.store(key, val)
		
		range_tmp = val
	
	end

	# last驍ｵ�ｺ髣悟ｿ洋驍ｵ�ｺ��ｨ髣包ｽｳ�鬮｢�ｾ��ｴ驍ｵ�ｺ陷ｷ�ｶ�迢暦ｽｸ�ｺ��ｮ驍ｵ�ｺ��ｧlast髯区ｻゑｽｽ�､驍ｵ�ｺ��ｨ髮球�驍ｵ�ｺ雋��ｪ��驍ｵ�ｺ��ｹ驍ｵ�ｺ陷･�ｲ��｢��ｺ鬩阪寒陬ｼ�ｲ遏ｩ蝮手滋�･���､驛｢�ｧ陷ｻ闌ｨ�ｽ�ｯ驕呈汚�ｽ�ｼ�
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





