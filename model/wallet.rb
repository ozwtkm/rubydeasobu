#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require_relative '../_util/SQL_transaction'

class Wallet
	attr_reader :user_id, :gem, :money

def initialize(wallet, user_id)

	@user_id = user_id
	@gem = wallet[:gem]
	@money = wallet[:money]

end


def self.get_wallet(user_id)

	sql_transaction =  SQL_transaction.instance.sql

	statement = sql_transaction.prepare("select gem,money from transaction.wallets where user_id = ? limit 1")
	result = statement.execute(user_id)
	statement.close
	
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


def save()

	sql_transaction =  SQL_transaction.instance.sql

	statement = sql_transaction.prepare("update transaction.wallets set gem = ?, money = ? where user_id = ?")
	statement.execute(@gem, @money, @user_id)
	statement.close

end


end
