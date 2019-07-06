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
ATTACK = 0
SKILL = 1
ESCAPE = 2
ITEM = 3
AI = 4

NORMAL = 0


def initialize(battle_document)
	@friend = battle_document.friend
	@enemy = battle_document.enemy
	@history = battle_document.situation
	@order = self.calculate_order()
	@finish_flg = false
end


def self.get(userid)
	sql_transaction = SQL_transaction.instance.sql
	
	documentDB_client = DocumentDB.instance
	collection = documentDB_client[:battle]

	battle_document = documentDB_client.find({"userid":userid})

	if battle_documentが空(つまり1ターン目
		insert into transaction.battle(user_id,turn) values(useid,1)
		
		select player_monster,partner_monster from quest

		select * from monsters where id = player_monster_id or partner_monster_id
		
		documentDB_client.insert({iroiro})
		battle_document = insertしたのと同じhash
	else
		# todo memcached
		# turn,user_id
		statement = sql_master.prepare("select * from transaction.battle where user_id = ? limit 1")
		result = statement.execute(userid)
		
		Validator.validate_SQL_error(result.count)
	
		self.check_db_consistency()
	end

	battle = Battle.new(battle_document)

	return battle
end

#mongoの中身イメージ↓
db.battle.insert({"user_id":1,"situation":[{"turn":1,"friend_status":{"player_status":{"hp":10,"mp":2,"atk":5,"def":2,"speed":5",money":6},"partner_status":{"hp":10,"mp":2,"atk":5,"def":2,"speed":5",money":6}},"enemy_status":{"hp":10,"mp":2,"atk":5,"def":2,"speed":5",money":6}}},{"turn":2,"before_command":[1,3],"friend_status":{"player_status":{"hp":10,"mp":2,"atk":5,"def":2,"speed":5",money":6},"partner_status":{"hp":10,"mp":2,"atk":5,"def":2,"speed":5",money":6}},"enemy_status":{"hp":10,"mp":2,"atk":5,"def":2,"speed":5",money":6}}}]})	

# getのときは必ずやる処理だしコントローラじゃなくてmodel側によせたほうがいいかと？
self.check_db_consistency(turn_documentDB,turn_SQL)
	if turn_documentDB != turn_SQL
		raise
	end
end


def self.calculate_order()
	すばやさから行動順をけってい
end


def advance()
	
end


def save()
	
end



class Friend
	
end


class Enemy
	
end


end

