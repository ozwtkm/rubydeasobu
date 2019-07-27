#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
require 'mongo'
require 'json'
require 'securerandom'
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
	@player = Battle::Player.new(battle_document[:situation].last[:status].select {|k,v| !v[:is_friend]}.values[0]) # 長すぎてキモい
	@partner = Battle::Player.new(battle_document[:situation].last[:status].select {|k,v| v[:is_friend]}.values[0])
	@enemy = Battle::Enemy.new(battle_document[:situation].last[:status].select {|k,v| v[:is_friend].nil?}.values[0])

	@scene = battle_document[:situation].last[:scene]
	@finish_flg = false
end


def self.get(user_id)
self.debug_dbreset()
self.debug_get_dbinfo("－－－－－－get直後－－－－－－")
	documentDB_client = DocumentDB.instance.client
	collection = documentDB_client[:battle]

	battle_document = collection.find({"user_id":user_id})

	if battle_document.count === 0
		battle = self.start(user_id)
	else
		sql_transaction = SQL_transaction.instance.sql
		statement = sql_transaction.prepare("select * from transaction.battle where user_id = ? limit 1")
		result = statement.execute(user_id)

		Validator.validate_SQL_error(result.count)

		self.check_db_consistency(battle_document.first, result.first)

		statement.close

		battle = Battle.new(battle_document.first)
	end

	return battle
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

	statement1 = sql_transaction.prepare("select current_x,current_y,current_z,party_id,partner_monster from transaction.quest where user_id = ? limit 1")
	result1 = statement1.execute(user_id)
	Validator.validate_SQL_error(result1.count)

	statement2 = sql_transaction.prepare("select possession_monster_id from transaction.party where id = ? limit 1")
	result2 = statement2.execute(result1.first["party_id"])
	Validator.validate_SQL_error(result2.count)

	statement3 = sql_transaction.prepare("select monster_id from transaction.user_monster where id = ? limit 1")
	result3 = statement3.execute(result2.first["possession_monster_id"])
	Validator.validate_SQL_error(result3.count)


	statement4 = sql_transaction.prepare("select appearance_id from master.appearance_place where x= ? and y = ? and z = ? and type = 1 limit 1") #type:1 → monster
	result4 = statement4.execute(result1.first["current_x"],result1.first["current_y"],result1.first["current_z"])
	Validator.validate_SQL_error(result4.count)#戦闘マスに来てないのに戦闘開始しようとするとここでつかまる

	player_id = result3.first["monster_id"]
	partner_id = result1.first["partner_monster"]
	enemy_id = result4.first["appearance_id"]

	statement5 = sql_master.prepare("select * from master.monsters where id = ? or id = ? or id = ? limit 3")
	result5 = statement5.execute(player_id,partner_id,enemy_id)
	Validator.validate_SQL_error(result5.count,is_multi_line: true)

	player = result5.select{|k,v| k["id"] == player_id}[0]
	partner = result5.select{|k,v| k["id"] == partner_id}[0]
	enemy = result5.select{|k,v| k["id"] == enemy_id}[0]

	statement1.close
	statement2.close
	statement3.close
	statement4.close
	statement5.close

	next_acter = self.calculate_next_acter(player,partner,enemy)

	player == next_acter ? player["is_turn"]=true : player["is_turn"]=false
	partner == next_acter ? partner["is_turn"]=true : partner["is_turn"]=false
	enemy == next_acter ? enemy["is_turn"]=true : enemy["is_turn"]=false

	battle_info = {
		"user_id": user_id,
		"situation": [
			{
				"scene": 1,
				"status": {
					"player1": {
						"name": player["name"],
						"hp": player["hp"],
						"mp": player["mp"],
						"atk": player["atk"],
						"def": player["def"],
						"speed": player["speed"],
						"is_friend": false,
						"is_turn": player["is_turn"]
					},
					"player2": {
						"name": partner["name"],
						"hp": partner["hp"],
						"mp": partner["mp"],
						"atk": partner["atk"],
						"def": partner["def"],
						"speed": partner["speed"],
						"is_friend": true,
						"is_turn": partner["is_turn"]
					},
					"enemy1": {
						"name": enemy["name"],
						"hp": enemy["hp"],
						"mp": enemy["mp"],
						"atk": enemy["atk"],
						"def": enemy["def"],
						"speed": enemy["speed"],
						"money": enemy["money"],
						"is_turn": enemy["is_turn"]
					}
				}
			}
		]
	}

	collection.insert_one(battle_info)

	self.debug_get_dbinfo("－－－－－－documentDB 1ターン目 insert直後－－－－－－")

	statement = sql_transaction.prepare("insert into transaction.battle(user_id,scene) values(?,1)")
	statement.execute(user_id)
	statement.close

	self.debug_get_dbinfo("－－－－－－SQL 1ターン目 insert直後－－－－－－")

	battle = Battle.new(battle_info)

	return battle
end

# scene終了時次の行動は誰か？を決定する
def self.calculate_next_acter(*args) #オブジェクトごと渡してオブジェクトごと返す
	speed = []
	args.each do |row|
		speed << row["speed"]
	end

	max_speed = speed.max

	max_speed_acter = args.select{|row| row["speed"] === max_speed}

	if max_speed_acter.count != 1
		random = SecureRandom.random_number(max_speed_acter.count)
		next_acter = max_speed_acter[random]
	else
		next_acter = max_speed_acter[0]
	end

	return next_acter
end

# 1ターン目だけは特殊で、敵から行動する可能性がある
def advance()
	acter = get_acter()




	if @scene === 1

	else

	end
	calculate_next_acter()

	if get_acter != @enemy 
		save()
	end
end

def get_acter()
	if @player.is_turn
		return @player
	elsif @partner.is_turn
		return @partner
	elsif @enemy.is_turn
		return @enemy 
	end

	raise "行動番がいない"
end

def enemy_act()
	if !@finished && @situation.order === enemy
		@enemy.act() #一旦ランダムな対象に攻撃してくるだけでよい

		if @player.hp === 0 || @enemy.hp === 0
			@finished = true
		end

		@situation.increase_order()
	end
end

def player_act()
	if !@finished && @situation.order != @enemy
		if @situation.order === @supporter
			acter = @supporter
		else
			acter = @player
		end

		case @command
		when ATTACK then
			damage = acter.calculate_damage(kind: NORMAL)#敵のダメージ計算
			@enemy.hp -= damage
		when SKILL then

		when ITEM then

		when ESCAPE then

		when AI then

		end

		if @player.hp === 0 || @enemy.hp === 0
			@finished = true
		end

		@situation.increase_order()
	end
end


def handle_result()
	if @finished
		@quest = Quest.new(@user.id)

		if @enemy.hp === 0
			add_enemy()#仲間になるかの話
			get_reward(gold:true)#おいおいはモンスター経験値、プレイヤ経験値も計算。いったんgoldだけ
		elsif @player.hp === 0
			get_reward() #後々モンスター経験値
		elsif @situation.turn === 10
			#仕様次第。
		end
	end


	@player.save()
	@supporter.save()
	@enemy.save()
	@situation.save()

	@context[:situation] = @situation
	@context[:player] = @player
	@contexr[:supporter] = @supporter
	@context[:enemy] = @enemy 
end


def add_enemy()
	random = 10
	if random < @enemy.probability
		@situation.is_add_monster = true
	end
end


def get_reward(gold: false, monster_exp: false, player_exp: false)
	if gold
		@quest.reward["gold"] += @enemy.gold
	end

	if monster_exp
		@quest.reward["monster_exp"] += @enemy.monster_exp
	end

	if player_exp
		@quest.reward["player_exp"] += @enemy.player_exp
	end
end







def save()
	sql update
	mongo update

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
		@is_friend=document["is_friend"]
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

	Log.log("－－－－－－－－－－－－－－－－－－－－－－－－")
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