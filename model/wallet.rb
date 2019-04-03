#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

class Wallet
	attr_reader :user_id, :gem, :money

def initialize(wallet, user_id)

	@user_id = user_id
	@gem = wallet[:gem]
	@money = wallet[:money]

end


def self.get_wallet(user_id, sql)

	statement = sql.prepare("select gem,money from transaction.wallets where user_id = ?")
	result = statement.execute(user_id)
	
	wallet_result = {}
	result.each do |row|

		wallet_result.store(:gem, row["gem"])
		wallet_result.store(:money, row["money"])
				
	end

	wallet = Wallet.new(wallet_result, user_id)
	
	return wallet

end


def sub_gem(num)

	# controller側だけでなくmodel側でも残量がnum以下のチェックをしてもいいかも。
	# todo sqlたたかずインスタンス変数更新する。

	@gem -= num

end


def save(sql)

	statement = sql.prepare("update transaction.wallets set gem = ?, money = ? where user_id = ?")
	statement.execute(@gem, @money, @user_id)

end


end
