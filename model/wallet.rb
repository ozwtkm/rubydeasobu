#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

class Wallet
	attr_reader :wallet

def initialize(wallet)

	@wallet = wallet

end


def self.get_wallet(user_id, sql)

	wallet_result = {}
	wallet_result[:id] = user_id
	wallet_result[:gem] = get_gem(user_id, sql)
	wallet_result[:money] = get_money(user_id, sql)

	wallet = Wallet.new(wallet_result)
	
	return wallet

end


def sub_gem(num)

	# controller側だけでなくmodel側でも残量がnum以下のチェックをしてもいいかも。
	# todo sqlたたかずインスタンス変数更新する。

	@wallet[:gem] -= num

end


def save(sql)

	statement = sql.prepare("update transaction.wallets set gem = ?, money = ? where user_id = ?")
	statement.execute(@wallet[:gem], @wallet[:money], @wallet[:id])

end


private


def self.get_money(user_id, sql)

	statement = sql.prepare("select money from transaction.wallets where user_id = ?")
	result_tmp = statement.execute(user_id)
	
	result = nil
	result_tmp.each do |row|

		result = row["money"]
				
	end

	return result

end


def self.get_gem(user_id, sql)

	statement = sql.prepare("select gem from transaction.wallets where user_id = ?")
	result_tmp = statement.execute(user_id)
	
	result = nil
	result_tmp.each do |row|

		result = row["gem"]
				
	end

	return result

end


end
