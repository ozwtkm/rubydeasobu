#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

class Wallet

def initialize(sql)

	@sql = sql

end


def self.get_wallet(sql)

	wallet = Wallet.new(sql)
	
	return wallet

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


def get_money(user_id)

	statement = @sql.prepare("select money from transaction.wallets where user_id = ?")
	result_tmp = statement.execute(user_id)
	
	result = nil
	result_tmp.each do |row|

		result = row["money"]
				
	end

	return result

end



end





