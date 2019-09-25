#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require_relative '../_util/SQL_transaction'
require_relative './basemodel'

class Wallet < Base_model
INITIAL_GEM = 1000
INITIAL_MONEY = 1000

attr_reader :user_id, :gem, :money

def initialize(wallet, user_id)
	@user_id = user_id
	@gem = wallet["gem"]
	@money = wallet["money"]
end


def self.get_wallet(user_id)
	sql_transaction =  SQL_transaction.instance.sql

	statement = sql_transaction.prepare("select gem,money from wallets where user_id = ? limit 1")
	result = statement.execute(user_id)
	
	Validator.validate_SQL_error(result.count)

	wallet = Wallet.new(result.first, user_id)

	statement.close
	
	return wallet
end


def self.init(user_id)
	sql_transaction =  SQL_transaction.instance.sql
	
	statement = sql_transaction.prepare("insert into wallets(user_id,money,gem) values(?,100,100)")
	statement.execute(user_id)
	statement.close()

	wallet = Wallet.new({"gem"=>INITIAL_GEM, "money"=>INITIAL_MONEY}, user_id)

	return wallet
end


def sub_gem(num)
	@gem -= num

	# コントローラでも検証を原則とするが、セーフティネットとして。
	if @gem < 0
		raise "カネ足りねえ"
	end
end


def save()
	sql_transaction =  SQL_transaction.instance.sql

	statement = sql_transaction.prepare("update wallets set gem = ?, money = ? where user_id = ?")
	statement.execute(@gem, @money, @user_id)
	statement.close()
end


end
