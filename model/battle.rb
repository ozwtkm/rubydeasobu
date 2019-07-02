#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'mongo'
require 'json'
require_relative '../_util/SQL_master'
require_relative '../_util/SQL_transaction'
require_relative '../_util/cache'
require_relative './basemodel'
require_relative '../exception/Error_inconsistency_of_aisle'
require_relative '../_util/documentDB'


class Battle

def initialize(friend,enemy)
	@friend = friend
	@enemy = enemy
	@history = {}
	@order = calculate_order()
	@turn = 1
	@finish_flg = false
end

#battleのからむ
#userid,turn,enemyid,partnerid,
def self.get(userid)
	sql_transaction = SQL_transaction.instance.sql
	
	# todo memcached
	# turn,user_id
	statement = sql_master.prepare("select * from transaction.battle where user_id = ?")
	result = statement.execute(userid)
	
	Validator.validate_SQL_error(result.count, is_multi_line: true)


	documentDB_client = DocumentDB.instance
	collection = documentDB_client[:battle]

	battle_document = documentDB_client.find({"userid":userid})

	if result.first.turn != battle_document.lastturn
		battle_document.delete(lastturn)
		raise
	end

	battle = Battle.new(battle_document)

	return battle
end


def self.advance()
	
end


def save()
	
end

class Friend
	
end


class Enemy
	
end

end



end

end

