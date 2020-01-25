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
    possession_monster_list = []

    user_monster_list = User_monster.get_possesion_info(user_id, limit:limit, offset:offset)

    user_monster_info = {}
    user_monster_list.each do |row|
        user_monster_info["id"] = row["id"]
        user_monster_info["user_id"] = row["user_id"]
        user_monster_info["monster_model"] = Monster.get_specific_monster(row["monster_id"])

        possession_monster_list << User_monster.new(user_monster_info)
    end

    possession_monster_list
end


def self.get_possesion_info(user_id, limit:10, offset:0)
    range = offset..(limit-1)
    array_for_identify_cached = Array.new(limit)
    user_monster_list = []

    # ＊取ってきたいrange内にキャッシュがあればそこは除いてSQL文を発行するようにしたい
    #  ＊range内にキャッシュがあるパターンは6種類あり、それぞれで発行すべきSQLが変わる
    #    1　冒頭n個がキャッシュされてる　→ 1~nを除外した範囲でSQLを発行
    #    2  最後尾n個がキャッシュされてる　→　-(1~n)を除外した範囲でSQLを発行
    #    3  冒頭n個と最後尾m個がキャッシュされてる　→　1~nと-(1~m)を除外した範囲でSQLを発行
    #    4  全部がキャッシュされてる　→　SQLの発行自体不要
    #    5  全くキャッシュなし　→　普通にそのままの範囲でSQL発行
    #    6  上記どれにも当てはまらない形で飛び飛びにキャッシュされてる　→　細かい範囲のSQLを複数発行と広い範囲のSQLを1発発行するのはどっちが重いんだ？
    range.each do |row|
        unless Cache.instance.get('user_monster:' + user_id.to_s + ':offset:' + row.to_s).nil?
            array_for_identify_cached[(row-offset)] = true
        end
    end

    # 上記6パターンに応じた処理の分岐をする（sql発行→cacheset→usermonsterモデルのリストを生成しuser_monster_listを構築）
    if array_for_identify_cached ~~~~
    elsif ~~~

    user_monster_list
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

