#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require_relative '../_util/SQL_transaction'

class Wallet
	attr_reader :user_id, :gem, :money

def initialize(wallet, user_id)

	@user_id = user_id
	@gem = wallet["gem"]
	@money = wallet["money"]

end


def self.get_wallet(user_id)

	sql_transaction =  SQL_transaction.instance.sql

	statement = sql_transaction.prepare("select gem,money from transaction.wallets where user_id = ? limit 1")
	result = statement.execute(user_id)

	wallet = Wallet.new(result.first, user_id)

	statement.close
	
	return wallet

end


# controller側だけでなくmodel側でも残量がnum以下のチェックをしてもいいかも。
def sub_gem(num)

	@gem -= num

end


def save()

	sql_transaction =  SQL_transaction.instance.sql

	statement = sql_transaction.prepare("update transaction.wallets set gem = ?, money = ? where user_id = ?")
	statement.execute(@gem, @money, @user_id)
	statement.close

end


end
