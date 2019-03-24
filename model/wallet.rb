#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

class Wallet

def initialize(wallet)

	@wallet = wallet

end


def self.get_wallet(user_id)

	wallet_result = {}
	wallet_result[:gem] = get_gem(user_id)
	wallet_result[:money] = get_money(user_id)

	wallet = Wallet.new(wallet_result)
	
	return wallet

end


def self.sub_gem(user_id, num)

	# controller側だけでなくmodel側でも残量がnum以下のチェックをしてもいいかも。

	statement = @sql.prepare("update transaction.wallets set gem = gem - ? where user_id = ?")
	statement.execute(num, user_id)

end


private


def get_money(user_id)

	statement = @sql.prepare("select money from transaction.wallets where user_id = ?")
	result_tmp = statement.execute(user_id)
	
	result = nil
	result_tmp.each do |row|

		result = row["money"]
				
	end

	return result

end


def get_gem(user_id)

	statement = @sql.prepare("select gem from transaction.wallets where user_id = ?")
	result_tmp = statement.execute(user_id)
	
	result = nil
	result_tmp.each do |row|

		result = row["gem"]
				
	end

	return result

end


end
