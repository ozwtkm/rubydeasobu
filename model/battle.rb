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
	@friend = battle_document.friend
	@enemy = battle_document.enemy
	@history = battle_document.situation
	@order = self.calculate_order()
	@finish_flg = false
end

		=begin
		battleが依存するDB↓
		
		1 quest
		今のuser_id,dangeon_id,x,y,z,party_id,partner_monster,obtain_money
		create table transaction.quest(user_id int(11) unsigned NOT NULL, dangeon_id int(10) unsigned NOT NULL, x int(5) unsigned NOT NULL, y int(5) unsigned NOT NULL,z int(5) unsigned NOT NULL, party_id int(5) unsigned NOT NULL, partner_monster int(11) unsigned NOT NULL,obtain_money int(10) unsigned NOT NULL,index (user_id),FOREIGN KEY (user_id) REFERENCES transaction.users(id),index (dangeon_id),FOREIGN KEY (dangeon_id) REFERENCES master.dangeons(id),index (party_id),FOREIGN KEY (party_id) REFERENCES transaction.party(id));
		
		2 出現table Acquisition
		user_id, x, y, z, タイプ(item=0, monter=1) id(アイテムid or モンスターid), info		create table transaction.quest_acquisition(user_id int(10) unsigned NOT NULL,x int(5) unsigned NOT NULL,y int(5) unsigned NOT NULL,z int(5) unsigned NOT NULL,type int(5) unsigned not null,acquisition_id int(10) unsigned not null,index (user_id),FOREIGN KEY (user_id) REFERENCES transaction.users(id));
		
		
		item とったとき -> info = 1
		item 捨てた -> info = 2
		monster battle start -> info = 2
		monster battle end and get -> info = 1
		
		3 party
		id,userid,monsterid
		create table transaction.party(id int(10) unsigned NOT NULL AUTO_INCREMENT,user_id int(10) unsigned NOT NULL,monster_id int(10) unsigned NOT NULL,primary key(id),index (user_id), FOREIGN KEY (user_id) REFERENCES transaction.users(id),index (monster_id),FOREIGN KEY (monster_id) REFERENCES master.monsters(id));
		
		4 place
		id,x,y,z,type
		create table master.acquisition_place(id int(10) unsigned NOT NULL AUTO_INCREMENT,x int(5) unsigned NOT NULL,y int(5) unsigned NOT NULL,z int(5) unsigned NOT NULL,type int(5) unsigned not null,primary key(id));
		
		=end

def self.get(userid)
	documentDB_client = DocumentDB.instance.client
	collection = documentDB_client[:battle]

	battle_document = documentDB_client.find({"userid":userid})

	if battle_document.count === 0
		self.start()
	else
		sql_transaction = SQL_transaction.instance.sql
	
		statement = sql_transaction.prepare("select * from transaction.battle where user_id = ? limit 1")
		result = statement.execute(userid)
		
		Validator.validate_SQL_error(result.count)
	
		self.check_db_consistency(battle_documentのturn,result.first["turn"])
		
		statement.close
		
		battle = Battle.new(battle_document)

	return battle
	end
end

#mongoの中身イメージ↓
=begin
{
	"user_id": 1,
	"situation": [
		{
			"turn": 1,
			"status": {
				"player1": {
					"name": "aaaaa",
					"hp": 10,
					"mp": 2,
					"atk": 5,
					"def": 2,
					"speed": 5,
					"is_frinend": 0
				},
				"player2": {
					"name": "bbbbb",
					"hp": 10,
					"mp": 2,
					"atk": 5,
					"def": 2,
					"speed": 5,
					"is_frinend": 1
				},
				"enemy1": {
					"name": "ccccc",
					"hp": 10,
					"mp": 2,
					"atk": 5,
					"def": 2,
					"speed": 5,
					"money": 6
				}
			}
		},
		{
			"turn": 2,
			"before_command": [
				1,
				3
			],
			"status": {
				"player1": {
					"name": "aaaaa",
					"hp": 10,
					"mp": 2,
					"atk": 5,
					"def": 2,
					"speed": 5,
					"is_frinend": 0
				},
				"player2": {
					"name": "bbbbb",
					"hp": 10,
					"mp": 2,
					"atk": 5,
					"def": 2,
					"speed": 5,
					"is_frinend": 1
				},
				"enemy1": {
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

self.check_db_consistency(turn_documentDB,turn_SQL)
	monogoの最終ターンをdelete

	if turn_documentDB != turn_SQL
		raise 
	end
end

self.start(userid)
	statement = sql_transaction.prepare("insert into transaction.battle(user_id,turn) values(?,1)")
	statement.execute(userid)
	statement.close
	
	statement1 = sql_transaction.prepare("select current_x,current_y,current_z,party_id,partner_monster from transaction.quest where user_id = ? limit 1")
	result1 = statement1.execute(userid)
	Validator.validate_SQL_error(result1.count)
	
	statement2 = sql_transaction.prepare("select monster_id from transaction.party where id = ? limit 1")
	result2 = statement2.execute(result1.first["party_id"])
	Validator.validate_SQL_error(result2.count)

	statement3 = sql_transaction.prepare("select acquisition_id from transaction.quest_acquisition where x= ? and y = ? and z = ? and type = 0 limit 1")
	result3 = statement3.execute(result1.first["current_x"],result1.first["current_y"],result1.first["current_z"])
	Validator.validate_SQL_error(result3.count)#戦闘マスに来てないのに戦闘開始しようとするとここでつかまる

	statement4 = sql_master.prepare("select * from monsters where id = ? or ? or ? limit 3")
	result4 = statement.execute(result1.first["partner_monster"],result2.first["monster_id"],result3.first["acquisition_id"])
	
	documentDB_client.insert({iroiro})
	battle_document = insertしたのと同じhash

	statement1.close
	statement2.close
	statement3.close
	statement4.close

	battle = Battle.new(battle_document)

	return battle
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

