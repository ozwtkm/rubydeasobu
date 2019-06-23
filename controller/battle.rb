#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'cgi'
require 'cgi/session'
require 'securerandom'
require 'json'
require_relative './_baseclass_require_login'
require_relative '../model/user'
require_relative '../model/monster'
require_relative '../model/wallet'
require_relative '../model/gacha'
require_relative '../exception/Error_shortage_of_gem'




class Battle_controller < Base_require_login
ATTACK = 0
SKILL = 1
ESCAPE = 2
ITEM = 3
AI = 4

NORMAL = 0

def initialize(req, res)
	@template = "battle.erb"
	super
	
	@player = Battle.get_player(@user.id)
	@supporter = Battle.get_supporter(@user.id)
	@enemy = Battle.get_enemy(@user.id)#1ターン目→questテーブル？から、誰とエンカウントするかを取得し、その情報をmonstersからselectし、battlemodelのenemyクラスをnewする　2ターン目以降→battlemodelからenemyとってくる
	

end

# オーバーライド。
def get_handler()
	@context[:player] = @player
	@context[:supporter] = @supporter
	@context[:enemy] = @enemy 
	super
end

def control()
	#リクエストの想定　["1","1"]　前者：コマンド　後者：コマンド詳細
	
	@situation = Battle.get_situation(@user.id) #order,turn,is_add_monster,history
	
	json = JSON.parse(@req.body)
	@command = json[0]
	@subcommand = json[1]
	@finished = false

	・mysqlもmongoもturn数もっておいて比較
	・異なってたらmongoだけさき進んじゃってることになるので復旧

	# 仲間にしますか？→はい、いいえ　の入力受付状態のとき用
	if @situation.is_add_monster
		if @command === 1
			Monster.add(@user.id,@monster.id)
		end
		
		handle_result()
		return
	end

	loop do
		enemy_act()
		player_act()
		
		# enemyが増えても大丈夫なように、（1ターン目のぞき）常に「次は味方の行動」という状態を保障
		if @situation.order != @enemy
			break
		end
	end
	
	handle_result()
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

end