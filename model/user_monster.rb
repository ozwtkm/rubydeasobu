#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
require_relative '../_util/sqltool'
require_relative '../_util/serializer'
require_relative '../_util/cache'
require_relative './monster'
require_relative './basemodel'
require_relative '../exception/Error_shortage_of_material'

# Monsterモデル→masterの方のmonsterテーブルに対するインターフェース
# User_monsterモデル→transactionの方のuser_monsterテーブルに対するインターフェース。
class User_monster < Base_model
	INITIAL_MONSTER_ID = 5 # 初期配布モンスター。本当は定数まとめファイルみたいなのにいるべきではある

	attr_reader :id, :user_id, :monster_id

def initialize(user_monster_info)
	@id = user_monster_info["id"]
    @user_id = user_monster_info["user_id"]
    @monster_model = user_monster_info["monster_model"]
end


def self.get_possession_monsters(user_id, limit:10, offset:0)
    user_monster_list = SQL.transaction("select * from user_monster where user_id = ? limit ? offset ?", [user_id,limit,offset])
    Validator.validate_SQL_error(user_monster_list.count, is_multi_line: true)

    user_monster_info = {}
    possession_monster_list = []
    user_monster_list.each do |row|
        user_monster_info["id"] = row["id"]
        user_monster_info["user_id"] = row["user_id"]
        user_monster_info["monster_model"] = Monster.get_specific_monster(row["monster_id"])

        possession_monster_list << User_monster.new(user_monster_info)
    end

    SQL.close_statement

    possession_monster_list
end


def self.get_specific_user_monster_info(user_monster_id, user_id=nil)
    if user_id.nil?
        specific_user_monster_info = SQL.transaction("select * from user_monster where id = ? limit 1", user_monster_id)
    else
        specific_user_monster_info = SQL.transaction("select * from user_monster where id = ? and user_id = ? limit 1", [user_monster_id, user_id])
    end

    Validator.validate_SQL_error(specific_user_monster_info.count, is_multi_line: false)

    SQL.close_statement

    specific_user_monster_info[0]
end


def self.add(user_id, monster_id)
	sql_transaction =  SQL_transaction.instance.sql

	statement = sql_transaction.prepare("insert into user_monster(user_id, monster_id) values(?,?)")
	statement.execute(user_id, monster_id)
	statement.close
end

def self.delete(user_id, monster_id, count)
	sql_transaction =  SQL_transaction.instance.sql

	begin
		statement = sql_transaction.prepare("delete from user_monster where user_id = ? and monster_id = ? limit ?")
		statement.execute(user_id, monster_id, count)
	rescue
		raise Error_shortage_of_material.new #party選択に含めてるモンスターを素材にしようとした時ここで怒る
	end

	if sql_transaction.affected_rows != count
		raise Error_shortage_of_material.new
	end

	statement.close
end

# ユーザ登録時だけ呼ばれる
def self.init(user_id)
	sql_transaction =  SQL_transaction.instance.sql

	statement = sql_transaction.prepare("insert into user_monster(user_id, monster_id) values(?,?)")
	statement.execute(user_id, 	INITIAL_MONSTER_ID)
	possession_monster_id = statement.last_id()

	statement.close

	return possession_monster_id
end

end

