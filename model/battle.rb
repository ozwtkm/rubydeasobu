#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
require 'mongo'
require 'json'
require 'securerandom'
require_relative '../_util/sqltool'
require_relative './basemodel'
require_relative '../_util/documentDB'
require_relative './quest'

# mongoのことdocumentって言ってるところのネーミング募集

class Battle < Base_model
	attr_accessor :user_id, :player, :partner, :enemy, :tmp_battle_result, :scene, :finish_flg, :add_enemy_flg

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
NEXT_NEXT = 1 # 1ターンめのみ使用する例外ステータス。初回行動がenemyだと、NEXTNEXTを設定しないと1ターンめに味方側の初手選択をできなくなる
NEXT = 2
DONE = 3

def initialize(battle_document=nil)
	@user_id = nil
	@player = nil
	@partner = nil
	@enemy = nil
	@history = nil
	@scene = nil
	@finish_flg = false
	@add_enemy_flg = false


	unless battle_document.nil?
		@user_id = battle_document[:user_id]

		@player = Battle::Player.new(battle_document[:situation].last[:status].select {|k,v| v[:is_partner]===false}.values[0]) # 長すぎてキモい
		@partner = Battle::Player.new(battle_document[:situation].last[:status].select {|k,v| v[:is_partner]}.values[0])
		@enemy = Battle::Enemy.new(battle_document[:situation].last[:status].select {|k,v| v[:is_partner].nil?}.values[0])
	
		@history = battle_document[:situation]
	
		@scene = battle_document[:situation].last[:scene]
	end
end


def self.get(user_id)
	dbinfo = Battle.get_db_info(user_id)
	document = dbinfo[:document]
	sql = dbinfo[:sql]

	if document.nil?
		raise "Battle取ってこれない"
	end

	battle = Battle.new(document)

	battle
end



# 各関数はDB情報が欲しい時、直接SQLやmongoから取得するのではなく、こいつを叩くようにする。
# そうすることで、常にself.check_db_consistencyが叩かれるので、
# それぞれの関数で都度意識することなくDBの生合成を維持できる。
def self.get_db_info(user_id)
	documentDB_client = DocumentDB.instance.client  
	collection = documentDB_client[:battle]

	document = collection.find({"user_id":user_id})
	sql = SQL.transaction("select * from battle where user_id = ?", user_id)

	Battle.check_db_consistency(document, sql, user_id)

	dbinfo = {}
	sql.count === 0 ? dbinfo[:sql] = nil : dbinfo[:sql] = sql[0]
	document.count === 0 ? dbinfo[:document] = nil : dbinfo[:document] = document.first

	dbinfo
end


#→新規「mongo→sql」、更新「mogno→sql」、削除「mongo→sql」という処理順番を守るようにすると、DBの状態で何が起きたかわかる
#＊mongoはあるがsqlがない　→ 新規作成時にエラーが起きたとわかる
#c　→ ターン更新時にエラーが起きたとわかる
#＊mongoはないがsqlがある　→ 削除時にエラーが起きたとわかる	　　
def self.check_db_consistency(document, sql, user_id)
	if document.count === 0
		# ＊mongoはないがsqlがある　→ 削除時にエラーが起きた
		if sql.count != 0
			SQL.transaction("delete from battle where user_id = ?", user_id)
			SQL.close_statement
	
			raise "sql側を消し損なってたのでsql消しといたよ"
		end
	else
		# ＊mongoはあるがsqlがない　→ 新規作成時にエラーが起きた
		if sql.count === 0
			SQL.close_statement
			collection.delete_one({"user_id":user_id})
	
			raise "sqlがinsertできてなかったのでmongo側をロールバック"
		end

		# ＊mongoもsqlもあるが、mongoのターンの方が未来
		if document.first["situation"].last["scene"] > sql[0]["scene"]
			SQL.close_statement
			document.first["situation"].pop
			collection.replace_one({"user_id":user_id}, document.first)
	
			raise "ターン更新時エラーになってたっぽいのでmogoをpoped"
		end

		# 「mongo→SQLの順に処理する」という決まりを徹底しておけばこのパターンは起こりえないため、本来は検証する必要はないが、
		# ヒューマンエラーなどを考慮し実際的な保険として一応しておく。
		if document.first["situation"].last["scene"] < sql[0]["scene"]
			# ここに来る時点でバグいこと確定なので小賢しいことせずバトル自体リセットする
			collection.delete_one(user_id: user_id)
			SQL.transaction("delete from battle where user_id = ?", user_id)
			SQL.close_statement

			raise "なぜかSQLが先行してるというありえない状況だったのでバトルリセット"
		end

		# todo：仕様上はありえないけどヒューマンエラー的に発生しうる不整合パターンを洗い出して一応検証処理書く
	end
end


def self.exist?(user_id)
	document = Battle.get_db_info(user_id)[:document]

	if document.nil?
		return false
	end

	return true
end

# questmodelから叩かれる。
def self.start(user_id, player_id, partner_id, enemy_id)
	if Battle.exist?(user_id)
		raise "目の前の戦闘に集中しなさい"
	end

	battle = Battle.new()

	battle.user_id = user_id

	# ここでのSQLエラーはmonsterモデル内で吐かれる
	player = Monster.get_specific_monster(player_id)
	partner = Monster.get_specific_monster(partner_id)
	enemy = Monster.get_specific_monster(enemy_id)

	hash_for_player_initialize = {
		:name => player.name,
		:hp => player.hp,
		:mp => player.mp,
		:atk => player.atk,
		:def => player.def,
		:speed => player.speed,
		:is_partner => false,
		:turn => INCOMPLETE
	}

	hash_for_partner_initialize = {
		:name => partner.name,
		:hp => partner.hp,
		:mp => partner.mp,
		:atk => partner.atk,
		:def => partner.def,
		:speed => partner.speed,
		:is_partner => true,
		:turn => INCOMPLETE
	}

	hash_for_enemy_initialize = {
		:name => enemy.name,
		:hp => enemy.hp,
		:mp => enemy.mp,
		:atk => enemy.atk,
		:def => enemy.def,
		:speed => enemy.speed,
		:money => enemy.money,
		:turn => INCOMPLETE
	}

	battle.player = Battle::Player.new(hash_for_player_initialize)
	battle.partner = Battle::Player.new(hash_for_partner_initialize)
	battle.enemy = Battle::Enemy.new(hash_for_enemy_initialize)

	next_acter = battle.calculate_next_acter()
	next_acter.turn = NEXT

	# 敵から行動だと、プレイヤー側の初手で誰が行動するかわからなくなるので例外的に「次の次」を計算
	if battle.enemy == next_acter
		next_next_acter = battle.calculate_next_acter()
		next_next_acter.turn = NEXT_NEXT
	end

	battle.insert_document()

	#self.debug_get_dbinfo("－－－－－－documentDB 1ターン目 insert直後－－－－－－")

	SQL.transaction("insert into battle(user_id,scene) values(?,0)", user_id)

	#self.debug_get_dbinfo("－－－－－－SQL 1ターン目 insert直後－－－－－－")

	SQL.close_statement

	return battle
end


def insert_document()
	documentDB_client = DocumentDB.instance.client
	collection = documentDB_client[:battle]

	battle_info = {
		"user_id": @user_id,
		"situation": [
			{
				"scene": 0,
				"status": {
					"player1": {
						"name": @player.name,
						"hp": @player.hp,
						"mp": @player.mp,
						"atk": @player.atk,
						"def": @player.def,
						"speed": @player.speed,
						"is_partner": @player.is_partner,
						"turn": @player.turn
					},
					"player2": {
						"name": @partner.name,
						"hp": @partner.hp,
						"mp": @partner.mp,
						"atk": @partner.atk,
						"def": @partner.def,
						"speed": @partner.speed,
						"is_partner": @partner.is_partner,
						"turn": @partner.turn
					},
					"enemy1": {
						"name": @enemy.name,
						"hp": @enemy.hp,
						"mp": @enemy.mp,
						"atk": @enemy.atk,
						"def": @enemy.def,
						"speed": @enemy.speed,
						"money": @enemy.money,
						"turn": @enemy.turn
					}
				}
			}
		]
	}

	collection.insert_one(battle_info)
end



def calculate_next_acter()
	candidate = get_acters(type: INCOMPLETE)

	# ターンが一巡すると全員DONEになってるのでリフレッシュ
	if candidate.count === 0
		if get_acters(type: DONE).count != 3
			raise "順番が矛盾してる"
		end

		@player.turn = INCOMPLETE
		@partner.turn = INCOMPLETE
		@enemy.turn = INCOMPLETE

		candidate = [@player,@partner,@enemy]
	end

	speed = []
	candidate.each do |row|
		speed << row.speed
	end

	max_speed = speed.max

	max_speed_acter = candidate.select{|row| row.speed === max_speed}

	if max_speed_acter.count != 1
		random = SecureRandom.random_number(max_speed_acter.count)
		next_acter = max_speed_acter[random]
	else
		next_acter = max_speed_acter[0]
	end

	return next_acter
end


# 1シーン目だけは特殊で、敵から行動する可能性がある
def advance(command,subcommand)
	loop do
		act(command,subcommand)

		if @finish_flg
			handle_result()
			return
		end

		set_next_acter()

		update_history()
		
		if @player.turn === NEXT || @partner.turn === NEXT
			break
		end
	end

	save()
end


def set_next_acter()
	next_next_acter = get_acters(type: NEXT_NEXT)

	unless next_next_acter.nil?
		next_next_acter.turn = NEXT
		return
	end

	next_acter = calculate_next_acter()
	next_acter.turn = NEXT
end


def get_acters(type:)
	acters = []

	case type
	when NEXT_NEXT
		acters = [@player,@partner,@enemy].select {|x| x.turn === NEXT_NEXT}

		return acters[0]
	when NEXT
		acters = [@player,@partner,@enemy].select {|x| x.turn === NEXT}
		if acters.count != 1
			raise "次の手番がなぜか1人じゃない"
		end

		return acters[0]
	when INCOMPLETE
		acters = [@player,@partner,@enemy].select {|x| x.turn === INCOMPLETE}
	when DONE
		acters = [@player,@partner,@enemy].select {|x| x.turn === DONE}
	end

	return acters
end


def update_history()
	# 「シーン：@sceneでの行動"後"の状況はこうですよ」
	@history << {
		"scene": @scene,
		"status": {
			"player1": {
				"name": @player.name,
				"hp": @player.hp,
				"mp": @player.mp,
				"atk": @player.atk,
				"def": @player.def,
				"speed": @player.speed,
				"is_partner": false,
				"turn": @player.turn
			},
			"player2": {
				"name": @partner.name,
				"hp": @partner.hp,
				"mp": @partner.mp,
				"atk": @partner.atk,
				"def": @partner.def,
				"speed": @partner.speed,
				"is_partner": true,
				"turn": @partner.turn
			},
			"enemy1": {
				"name": @enemy.name,
				"hp": @enemy.hp,
				"mp": @enemy.mp,
				"atk": @enemy.atk,
				"def": @enemy.def,
				"speed": @enemy.speed,
				"money": @enemy.money,
				"turn": @enemy.turn
			}
		}
	}

end

def act(command,subcommand)
	@scene += 1
	acter = get_acters(type: NEXT)

	if acter == @player || acter == @partner
		player_act(acter,command,subcommand)
	else
		enemy_act()
	end

	if [@player, @enemy].any?{|x| x.hp <= 0}
		@finish_flg = true
	end

	acter.turn = DONE
end

# ランダムに味方一体を殴ってくるだけ。とりあえずは
def enemy_act()
	random = SecureRandom.random_number([@player,@partner].count)
	target = [@player,@partner][random]

	damage = calculate_damage(attacker: @enemy, target: target, kind: NORMAL)
	target.hp -= damage
	target.hp = 0 if target.hp < 0
end


def player_act(acter,command,subcommand)
	case command
	when ATTACK then
		damage = calculate_damage(attacker: acter, target: @enemy, kind: NORMAL)
		@enemy.hp -= damage
		@enemy.hp = 0 if @enemy.hp < 0
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
		damage = 0 if damage < 0
	when SPECIAL
	# 火炎斬りとかだとatk*1.2 - def みたいな感じになる
	end 

	return damage
end

def handle_result()
	if @enemy.hp <= 0
		handle_add_enemy()#仲間になるかの話
		get_reward(gold:true)#おいおいはモンスター経験値、プレイヤ経験値も計算。いったんgoldだけ

		if @scene <= 30
			#早期Ternクリア報酬
		end
	elsif @player.hp <= 0
		get_reward() #後々モンスター経験値導入
	end

	close_battle()
end

# 仲間にしますか？の処理。とりあえず固定確率にしとく
def handle_add_enemy()
	random = SecureRandom.random_number(100) 

	if random < 0 # 一旦後回し
		@add_enemy_flg = true

		# add_monster的なテーブルにinsert
	end
end


def get_reward(gold: false, monster_exp: false, player_exp: false)
	if gold
		SQL.transaction("update quest set obtain_money = obtain_money + ? where user_id = ?", [@enemy.money, @user_id])
	end

	# あとで
	if monster_exp

	end

	 # あとで
	if player_exp

	end

	SQL.close_statement()
end


def save()
	documentDB_client = DocumentDB.instance.client
	collection = documentDB_client[:battle]

	sql_transaction = SQL_transaction.instance.sql
	
	collection.update_one({user_id: @user_id}, '$set' => {situation: @history})

	SQL.transaction("update battle set scene = ? where user_id = ?", [@scene, @user_id])
	SQL.close_statement()

	Battle.debug_get_dbinfo("save実行直後")
end


def close_battle()
	documentDB_client = DocumentDB.instance.client
	collection = documentDB_client[:battle]

	collection.delete_one(user_id: @user_id)

	SQL.transaction("delete from battle where user_id = ?", @user_id)
	SQL.close_statement()

	Battle.debug_get_dbinfo("close_battle実行直後")
end

class Player
attr_reader :name, :is_partner
attr_accessor :hp, :mp, :atk, :def, :speed, :turn

	def initialize(document)
		@name=document[:name]
		@hp=document[:hp]
		@mp=document[:mp]
		@atk=document[:atk]
		@def=document[:def]
		@speed=document[:speed]
		@is_partner=document[:is_partner]
		@turn=document[:turn]
	end
end


class Enemy
attr_reader :name, :money
attr_accessor :hp, :mp, :atk, :def, :speed, :turn

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

def self.debug_dbreset() 
	Log.log("－－－－－－－DB RESET－－－－－－－－")

	sql_transaction = SQL_transaction.instance.sql
	statement =sql_transaction.prepare("delete from battle")
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
	statement =sql_transaction.prepare("select * from battle")
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