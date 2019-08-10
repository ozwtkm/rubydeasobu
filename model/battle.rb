#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
require 'mongo'
require 'json'
require 'securerandom'
require_relative '../_util/SQL_master'
require_relative '../_util/SQL_transaction'
require_relative './basemodel'
require_relative '../_util/documentDB'
require_relative './quest'

class Battle
	attr_reader :user_id, :player, :partner, :enemy, :tmp_battle_result, :scene, :finish_flg, :add_enemy_flg

#コマンド識別用
ATTACK = 0
SKILL = 1
ESCAPE = 2
ITEM = 3
AI = 4

# ダメージ計算用
NORMAL = 0
SPECIAL = 1

#ターン内での行動順管理用
INCOMPLETE = 0
NEXT = 1
DONE = 2

def initialize(battle_document, next_next_acter :nil)
	@user_id = battle_document[:user_id]

	@player = Battle::Player.new(battle_document[:situation].last[:status].select {|k,v| v[:is_friend]===false}.values[0]) # 長すぎてキモい
	@partner = Battle::Player.new(battle_document[:situation].last[:status].select {|k,v| v[:is_friend]}.values[0])
	@enemy = Battle::Enemy.new(battle_document[:situation].last[:status].select {|k,v| v[:is_friend].nil?}.values[0])

	@tmp_battle_result = {}
	@tmp_battle_result["situation"] = []

	@scene = battle_document[:situation].last[:scene]
	@finish_flg = false
	@add_enemy_flg = false
end


def self.get(user_id)
#self.debug_dbreset()
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

	player == next_acter ? player["turn"]=NEXT : player["turn"]=INCOMPLETE
	partner == next_acter ? partner["turn"]=NEXT : partner["turn"]=INCOMPLETE
	enemy == next_acter ? enemy["turn"]=NEXT : enemy["turn"]=INCOMPLETE

	# 敵から行動だと、プレイヤー側の初手誰が行動するかわからなくなる
	if enemy == next_acter
		next_next_acter = self.calculate_next_acter(player,partner)
	end

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
						"turn": player["turn"]
					},
					"player2": {
						"name": partner["name"],
						"hp": partner["hp"],
						"mp": partner["mp"],
						"atk": partner["atk"],
						"def": partner["def"],
						"speed": partner["speed"],
						"is_friend": true,
						"turn": partner["turn"]
					},
					"enemy1": {
						"name": enemy["name"],
						"hp": enemy["hp"],
						"mp": enemy["mp"],
						"atk": enemy["atk"],
						"def": enemy["def"],
						"speed": enemy["speed"],
						"money": enemy["money"],
						"turn": enemy["turn"]
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

	battle = Battle.new(battle_info, next_next_acter :next_next_acter:)

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
def advance(command,subcommand)
	acter = get_acters(type: NEXT)[0]

	loop do
		act(acter,command,subcommand)

		if @finish_flg
			break
		end

		acter = set_next_acter(acter)
		
		if acter != @enemy
			break
		end
	end

	if @finish_flg
		handle_result()
	else
		save()
	end
end


def set_next_acter(acter)
	candidate　= get_acters(type: INCOMPLETE)
	next_acter = Battle.calculate_next_acter(candidate)

	acter["turn"] = DONE

	@player["turn"] = NEXT if @player == next_acter
	@partner["turn"] = NEXT if @partner == next_acter
	@enemy["turn"] = NEXT if @enemy == next_acter

	return next_acter
end


def get_acters(type:)
	acters = []

	case type
	when NEXT
			acters << @player if @player.turn === NEXT
			acters << @partner if @partner.turn === NEXT
			acters << @enemy if @enemy.turn === NEXT

			if acters.count != 1
				raise "順番おかしい"
			end
	when INCOMPLETE
			acters << @player if @player.turn === INCOMPLETE
			acters << @partner if @partner.turn === INCOMPLETE
			acters << @enemy if @enemy.turn === INCOMPLETE
	when DONE
			acters << @player if @player.turn === DONE
			acters << @partner if @partner.turn === DONE
			acters << @enemy if @enemy.turn === DONE
	end

	return acters
end


def act(acter,command,subcommand)
	if acter == @player || acter == @partner
		player_act(acter,command,subcommand)
	else
		enemy_act(acter)
	end

	@scene += 1
	@tmp_battle_result["situation"] << {
		"scene": @scene,
		"status": {
			"player1": {
				"name": @player.name,
				"hp": @player.hp,
				"mp": @player.mp,
				"atk": @player.atk,
				"def": @player.def,
				"speed": @player.speed,
				"is_friend": false,
				"turn": @player["turn"]
			},
			"player2": {
				"name": @partner.name,
				"hp": @partner.hp,
				"mp": @partner.mp,
				"atk": @partner.atk,
				"def": @partner.def,
				"speed": @partner.speed,
				"is_friend": true,
				"turn": @partner["turn"]
			},
			"enemy1": {
				"name": @enemy.name,
				"hp": @enemy.hp,
				"mp": @enemy.mp,
				"atk": @enemy.atk,
				"def": @enemy.def,
				"speed": @enemy.speed,
				"money": @enemy.money,
				"turn": @enemy["turn"]
			}
		}
	}

	if [@player,@partner,@enemy].any?{|x| x.hp <= 0}
		@finish_flg = true
	end
end

# ランダムに味方一体を殴ってくるだけ。とりあえずは
def enemy_act()
	random = SecureRandom.random_number([@player,@partner].count)
	target = [@player,@partner][random]

	damage = calculate_damage(attacker: @enemy, target: target, kind: NORMAL)
	target.hp -= damage
	target.hp = 0 if target.hp.negative?
end


def player_act(acter,command,subcommand)
	case command
	when ATTACK then
		damage = calculate_damage(attacker: acter, target: @enemy, kind: NORMAL)
		@enemy.hp -= damage
		@enemy.hp = 0 if @enemy.hp.negative?
	when SKILL then

	when ITEM then

	when ESCAPE then

	when AI then

	end
end

def calculate_damage(attacker: ,target: ,kind:)
	case kind
	when NORMAL
		damage = attacker.atk - target.def
		damage = 0 if damage.negative?
	when SPECIAL
	# 火炎斬りとかだとatk*1.2 - def みたいな感じになる
	end 

	return damage
end

def handle_result()
	quest = Quest.get(@user_id) # modelの中でmodelをnewするのはアリなのか？

	if @enemy.hp <= 0
		check_add_enemy()#仲間になるかの話
		get_reward(gold:true)#おいおいはモンスター経験値、プレイヤ経験値も計算。いったんgoldだけ

		if @scene <= 30
			#早期Ternクリア報酬
		end
	elsif @player.hp <= 0
		get_reward() #後々モンスター経験値導入
	end

	quest.save()

	close_battle()
end


def add_enemy()
	random = 10
	if random < @enemy.probability
		@situation.is_add_monster = true
	end
end


def get_reward(gold: false, monster_exp: false, player_exp: false)
	if gold
		quest.reward["gold"] += @enemy.money
	end

	# あとで
	if monster_exp

	end

	 # あとで
	if player_exp

	end
end


def save()
	documentDB_client = DocumentDB.instance.client
	collection = documentDB_client[:battle]
	
	# 動作確認
	collection.find(user_id: @user_id).replace_one(@tmp_battle_result["situation"])

	sql_transaction = SQL_transaction.instance.sql
	statement = sql_transaction.prepare("update battle set scene = ? where user_id = ?")
	statement.execute(@scene, @user_id)
end


def close_battle()
	documentDB_client = DocumentDB.instance.client
	collection = documentDB_client[:battle]
	
	# あとで動作確認
	collection.remove(user_id: @user_id)

	sql_transaction = SQL_transaction.instance.sql
	statement = sql_transaction.prepare("delete from battle where user_id = ?")
	statement.execute(@user_id)
end

class Player
attr_reader :name, :is_friend
attr_accessor :hp, :mp, :atk, :def, :speed, :turn

	def initialize(document)
		@name=document[:name]
		@hp=document[:hp]
		@mp=document[:mp]
		@atk=document[:atk]
		@def=document[:def]
		@speed=document[:speed]
		@is_friend=document[:is_friend]
		@turn=document[:turn]
	end
end


class Enemy
attr_reader :name, :money
attr_accessor :hp, :mp, :atk, :def, :speed

	def initialize(document)
		@name=document[:name]
		@hp=document[:hp]
		@mp=document[:mp]
		@atk=document[:atk]
		@def=document[:def]
		@speed=document[:speed]
		@money=document[:money]
		@turn=document[:turn]
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