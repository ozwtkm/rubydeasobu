#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require_relative '../_util/SQL_master'
require_relative '../_util/SQL_transaction'
require_relative './basemodel'
require_relative './map'
require_relative '../_util/documentDB'
require_relative '../_util/validator'


class Quest < Base_model    
attr_accessor :dangeon_info, :team_info, :current_x, :current_y, :current_z

# quest状況管理用
WALKING = 0
BATTLE = 1
EVENT = 2

# acquisition用
UNTOUCHED = 0
ACKQUIRED = 1
DISDISCARDED = 2

# appearance_placeの名前解決用。こういうの用のmasterファイル作っておきたい。
MONSTER = 1
ITEM = 2
EQUIPMENT = 3

def initialize(user_id,dangeon_info,team_info,current_x,current_y,current_z)
    @user_id = user_id

    @dangeon_info = dangeon_info
    @team_info = team_info

    #@situation = situation # 現状の仕様なら無くても成立はする。

    @current_x = current_x
    @current_y = current_y
    @current_z = current_z
end


def self.start(user_id, partner_id, party_id, quest_id)
    Quest.debug_reset_quest()

    Quest.check_start_condition(user_id, partner_id, party_id, quest_id)

    sql_transaction = SQL_transaction.instance.sql


    dangeon_info = {}
    dangeon_info["id"] = quest_id
    dangeon_info["map"] = Map.get(quest_id,1)

    team_info = {}
    team_info["party"] = party_id
    team_info["partner"] = partner_id

    statement = sql_transaction.prepare("insert into quest(user_id,dangeon_id,current_x,current_y,current_z,party_id,partner_monster,obtain_money) values(?,?,?,?,?,?,?,?)")
    result = statement.execute(user_id, quest_id, 0, 0, 1, party_id, partner_id, 0)

    statement.close()

    quest = Quest.new(user_id, dangeon_info, team_info, 0, 0, 1)
end


def self.get(user_id)
    sql_transaction = SQL_transaction.instance.sql
	sql_master = SQL_master.instance.sql

    statement = sql_transaction.prepare("select * from quest where user_id = ?")
    result = statement.execute(user_id)

    Validator.validate_SQL_error(result.count, is_multi_line: false)

    dangeon_info = {}
    dangeon_info["id"] = result.first["dangeon_id"]
    dangeon_info["map"] = Map.get(result.first["dangeon_id"],0)

    team_info = {}
    team_info["party"] = result.first["party_id"]
    team_info["partner"] = result.first["partner_monster"]

    x = result.first["current_x"]
    y = result.first["current_y"]
    z = result.first["current_z"]

    quest = Quest.new(user_id, dangeon_info, team_info, x, y, z)

    return quest
end


def self.check_start_condition(user_id, partner_id, party_id, quest_id)
    sql_transaction = SQL_transaction.instance.sql
	sql_master = SQL_master.instance.sql

    statement = sql_transaction.prepare("select * from quest where user_id = ? limit 1")
    result = statement.execute(user_id)

    if result.count === 1
        raise "既に別クエスト実施中"
    end

    # 追々はcondidate_partnerみたいなテーブルで検証
    statement = sql_master.prepare("select * from monsters where id = ? limit 1")
    result = statement.execute(quest_id)


    # 追々はcondidate_dangeonみたいなテーブルで検証（進行するごとに増えてく
    statement = sql_master.prepare("select * from dangeons where id = ? limit 1")
    result = statement.execute(quest_id)

    Validator.validate_SQL_error(result.count, is_multi_line: false)
   

    statement = sql_transaction.prepare("select * from party where id = ? limit 1")
    result = statement.execute(party_id)

    Validator.validate_SQL_error(result.count, is_multi_line: false)

    statement.close()
end



def save()

end

# debug用
def self.debug_reset_quest()
    sql_transaction = SQL_transaction.instance.sql
	sql_master = SQL_master.instance.sql

    statement = sql_transaction.prepare("delete from quest")
    statement.execute()

    Log.log("Quest is reseted")
end

end