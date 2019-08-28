#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
require_relative '../_util/SQL_transaction'
require_relative '../_util/SQL_master'
require_relative './basemodel'
require_relative './monster'


class Party < Base_model
    attr_reader :id, :monster_model
    attr_accessor :possession_monster_id

def initialize(party_info)
    @id = party_info["id"]
    @user_id = party_info["user_id"]
    @possession_monster_id = party_info["possession_monster_id"] #現仕様では1パーティにつき一体だけ
    @monster_model = party_info["monster_model"]
end

# 多分改良の余地がある。TO do
def self.get(user_id)
    sql_transaction = SQL_transaction.instance.sql
    sql_master = SQL_master.instance.sql

    statement1 = sql_transaction.prepare("select id, possession_monster_id from party where user_id = ? limit 3")
    result1 = statement1.execute(user_id)
    #仕様としてpartyの上限数は3としてる。

	Validator.validate_SQL_error(result1.count, is_multi_line: true)
    
    tmp_possession_monster_id = []
    tmp_id = []
    result1.each do |row|
        tmp_possession_monster_id << row["possession_monster_id"]
        tmp_id << row["id"]
    end

    # 1回のSQLだと、「どのpartyがどのmonsterか」という対応が分からなくなるから苦肉のloop    
    statement2 = sql_transaction.prepare("select monster_id from user_monster where id = ? limit 1")
    tmp_monster_id = []
    tmp_possession_monster_id.each do |row|
        result2 = statement2.execute(row)

        Validator.validate_SQL_error(result2.count, is_multi_line: false)

        tmp_monster_id << result2.first()["monster_id"]
    end

    statement3 = sql_master.prepare("select * from monsters where id = ? limit 1")
    monsters = []
    tmp_monster_id.each do |row|
        result3 = statement3.execute(row)

        Validator.validate_SQL_error(result3.count, is_multi_line: false)

        monsters << result3.first()
    end

    parties = {}
    party_info = {}
    i = 0
    monsters.each do |row|
        party_info["monster_model"] = Monster.new(row)
        party_info["id"] = tmp_id[i]
        party_info["user_id"] = user_id
        party_info["possession_monster_id"] = tmp_possession_monster_id[i]

        parties[tmp_id[i]] = Party.new(party_info)
        i += 1
    end

    statement1.close
    statement2.close
    statement3.close

    return parties
end

# ユーザ新規登録時のみ叩かれる
def self.init(user_id, possession_monster_id)
    sql_transaction = SQL_transaction.instance.sql

    statement = sql_transaction.prepare("insert into party(user_id, possession_monster_id) values(?,?),(?,?),(?,?)")
    result = statement.execute(user_id,possession_monster_id,user_id,possession_monster_id,user_id,possession_monster_id)
    statement.close
end


def set(possession_monster_id)
    sql_transaction = SQL_transaction.instance.sql
    sql_master = SQL_master.instance.sql

    statement1 = sql_transaction.prepare("select monster_id from user_monster where id = ? and user_id = ? limit 1")
    result1 = statement1.execute(possession_monster_id, @user_id)

    Validator.validate_SQL_error(result1.count, is_multi_line: false)

    statement2 = sql_master.prepare("select * from monsters where id = ? limit 1")
    result2 = statement2.execute(result1.first()["monster_id"])

    Validator.validate_SQL_error(result2.count, is_multi_line: false)

    @monster_model = Monster.new(result2.first())
    @possession_monster_id = possession_monster_id

    statement1.close()
    statement2.close()
end

# init時に3枠が確保され、insertは使わずupdateだけが使われる仕様
def save()
    sql_transaction = SQL_transaction.instance.sql

    statement = sql_transaction.prepare("update party set possession_monster_id = ? where id = ?")
    statement.execute(@possession_monster_id, @id)
    statement.close()
end



end