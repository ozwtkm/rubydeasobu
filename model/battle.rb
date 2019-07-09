#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
require 'mongo'
require 'json'
require_relative '../_util/SQL_master'
require_relative '../_util/SQL_transaction'
require_relative './basemodel'
require_relative '../_util/documentDB'

class Battle
ATTACK = 0
SKILL = 1
ESCAPE = 2
ITEM = 3
AI = 4

NORMAL = 0


def initialize(battle_document)
	@player = Battle::Player.new(battle_document[:situation].last[:status].select {|k,v| v[:is_friend] === 0}.values[0]) # 長すぎてキモい
	@partner = Battle::Player.new(battle_document[:situation].last[:status].select {|k,v| v[:is_friend] === 1}.values[0])
	@enemy = Battle::Enemy.new(battle_document[:situation].last[:status].select {|k,v| v[:is_friend].nil?}.values[0])
	
	@finish_flg = false
end


def self.get(user_id)
self.debug_dbreset()
self.debug_get_dbinfo("－－－－－－get直後－－－－－－")
	documentDB_client = DocumentDB.instance.client
	collection = documentDB_client[:battle]

	battle_document = collection.find({"user_id":user_id})
	
	if battle_document.count === 0
		self.start(user_id)
	else
		sql_transaction = SQL_transaction.instance.sql
		statement = sql_transaction.prepare("select * from transaction.battle where user_id = ? limit 1")
		result = statement.execute(user_id)
		
		Validator.validate_SQL_error(result.count)
	
		self.check_db_consistency(battle_document.first, result.first)
		
		statement.close
		
		battle = Battle.new(battle_document.first)

	return battle
	end
end



def self.check_db_consistency(documentDB,sql)
	#バトル結果はdodumentDB→SQLの順にinsertするため、documentDBだけ1scene先行している可能性がある(レアケースだが
	if documentDB["situation"].last["scene"] != sql["scene"]
		documentDB_client = DocumentDB.instance.client
		collection = documentDB_client[:battle]
		user_id = documentDB["user_id"]
	
		documentDB["situation"].pop
		collection.replace_one({"user_id":user_id},documentDB)
		
		raise "poped"
	end
end


def self.start(user_id)
	sql_transaction = SQL_transaction.instance.sql
	sql_master = SQL_master.instance.sql
	
	documentDB_client = DocumentDB.instance.client
	collection = documentDB_client[:battle]
		
	statement = sql_transaction.prepare("insert into transaction.battle(user_id,scene) values(?,1)")
	statement.execute(user_id)
	statement.close
	
	self.debug_get_dbinfo("－－－－－－SQL 1ターン目 insert直後－－－－－－")
	
	statement1 = sql_transaction.prepare("select current_x,current_y,current_z,party_id,partner_monster from transaction.quest where user_id = ? limit 1")
	result1 = statement1.execute(user_id)
	Validator.validate_SQL_error(result1.count)
	
	statement2 = sql_transaction.prepare("select possession_monster_id from transaction.party where id = ? limit 1")
	result2 = statement2.execute(result1.first["party_id"])
	Validator.validate_SQL_error(result2.count)

	statement3 = sql_transaction.prepare("select appearance_id from master.appearance_place where x= ? and y = ? and z = ? and type = 1 limit 1") #type:1 → monster
	result3 = statement3.execute(result1.first["current_x"],result1.first["current_y"],result1.first["current_z"])
	Validator.validate_SQL_error(result3.count)#戦闘マスに来てないのに戦闘開始しようとするとここでつかまる

	statement4 = sql_master.prepare("select * from master.monsters where id = ? or id = ? or id = ? limit 3")
	result4 = statement4.execute(result1.first["partner_monster"],result2.first["monster_id"],result3.first["appearance_id"])
	Validator.validate_SQL_error(result4.count,is_multi_line: true)
	
	iroiro = {
		"user_id": 2,
		"situation": [
			{
				"scene": 1,
				"status": {
					"player1": {
						"acter_id":1,
						"name": "aaaaa",
						"hp": 10,
						"mp": 2,
						"atk": 5,
						"def": 2,
						"speed": 3,
						"is_friend": 0,
						"is_turn": 0
					},
					"player2": {
						"acter_id":2,
						"name": "bbbbb",
						"hp": 10,
						"mp": 2,
						"atk": 5,
						"def": 2,
						"speed": 5,
						"is_friend": 1,
						"is_turn": 0
					},
					"enemy1": {
						"acter_id":3,
						"name": "ccccc",
						"hp": 10,
						"mp": 2,
						"atk": 5,
						"def": 2,
						"speed": 5,
						"money": 6,
						"is_turn": 1
					}
				}
			}
		]
	}
	
	
	collection.insert_one(iroiro)
	battle_document = iroiro

	self.debug_get_dbinfo("－－－－－－documentDB 1ターン目 insert直後－－－－－－")

	statement1.close
	statement2.close
	statement3.close
	statement4.close
puts battle_document
	battle = Battle.new(battle_document)

	return battle
end

# scene終了時次の行動は誰か？を決定する
def calculate_next_order()
	
	
	return next_order
end

# 1ターン目だけは特殊で、敵から行動する可能性がある
def advance()
	
	calculate_next_order()
	save()
end


def save()
	
end



class Player
attr_reader :name, :is_friend
attr_accessor :hp, :atk, :def, :speed, :is_turn

	def initialize(document)
		@name=document["name"]
		@hp=document["hp"]
		@mp=document["mp"]
		@atk=document["atk"]
		@def=document["def"]
		@speed=document["speed"]
		@is_frined=document["is_friend"]
		@is_turn=document["is_turn"]
	end
end


class Enemy
attr_reader :name, :money
attr_accessor :hp, :atk, :def, :speed

	def initialize(document)
		@name=document["name"]
		@hp=document["hp"]
		@mp=document["mp"]
		@atk=document["atk"]
		@def=document["def"]
		@speed=document["speed"]
		@money=document["money"]
	end
end

private
def self.debug_dbreset() 
	Log.log("－－－－－－－DB RESET－－－－－－－－")

	sql_transaction = SQL_transaction.instance.sql
	statement =sql_transaction.prepare("delete from transaction.battle")
	statement.execute
	
	documentDB_client = DocumentDB.instance.client
	collection = documentDB_client[:battle]
	
	collection.drop()
	Log.log("－－－－－－－－－－－－－－－－－－－")
end


def self.debug_get_dbinfo(comment)
	Log.log(comment)
	
	Log.log("SQL--------------")
	sql_transaction = SQL_transaction.instance.sql
	statement =sql_transaction.prepare("select * from transaction.battle")
	result = statement.execute
	
	result.each do |row|
		Log.log(row.to_s)
	end
	
	Log.log("documentDB-------")
	documentDB_client = DocumentDB.instance.client
	collection = documentDB_client[:battle]
	result2 = collection.find()
	
	result2.each do |row|
		Log.log(row.to_s)
	end
	
	Log.log("－－－－－－－－－－－－－－－－－－－")
end

end

#mongoの中身イメージ↓
=begin
1reqで1scene追加されてく
{
	"user_id": 2,
	"situation": [
		{
			"scene": 1,
			"status": {
				"player1": {
					"acter_id":1,
					"name": "aaaaa",
					"hp": 10,
					"mp": 2,
					"atk": 5,
					"def": 2,
					"speed": 3,
					"is_friend": 0,
					"is_turn": 0
				},
				"player2": {
					"acter_id":2,
					"name": "bbbbb",
					"hp": 10,
					"mp": 2,
					"atk": 5,
					"def": 2,
					"speed": 5,
					"is_friend": 1,
					"is_turn": 0
				},
				"enemy1": {
					"acter_id":3,
					"name": "ccccc",
					"hp": 10,
					"mp": 2,
					"atk": 5,
					"def": 2,
					"speed": 5,
					"money": 6,
					"is_turn": 1
				}
			}
		},
		{
			"scene": 2,
			"berore":{
				"acter":1,
				"command":[
					1,
					3
				]
			},
			"status": {
				"player1": {
					"acter_id":1,
					"name": "aaaaa",
					"hp": 10,
					"mp": 2,
					"atk": 5,
					"def": 2,
					"speed": 5,
					"is_friend": 0,
					"is_turn": 0
				},
				"player2": {
					"acter_id":2,
					"name": "bbbbb",
					"hp": 10,
					"mp": 2,
					"atk": 5,
					"def": 2,
					"speed": 5,
					"is_friend": 1,
					"is_turn": 0
				},
				"enemy1": {
					"acter_id":3,
					"name": "ccccc",
					"hp": 10,
					"mp": 2,
					"atk": 5,
					"def": 2,
					"speed": 5,
					"money": 6
				}
			}
		}
	]
}
=end
