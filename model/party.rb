#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
require_relative '../_util/SQL_transaction'
require_relative '../_util/SQL_master'
require_relative '../_util/sqltool'
require_relative '../model/monster'
require_relative './basemodel'
require_relative './monster'


class Party < Base_model
    attr_reader :id, :monster_model
    attr_accessor :possession_monster_id

def initialize(party_info)
    @id = party_info["id"]
    @possession_monster_id = party_info["possession_monster_id"] #現仕様では1パーティにつき一体だけ
    @monster_model = party_info["monster_model"]
end

def self.get(user_id)
    parties_for_return = {} 
    party_list_template = {} # parties_for_returnを作るための一時的な箱の役割。こいつを形作って最後にこいつがeachしてparties_for_returnを作る。
    number_of_party_per_user = 3 # 仕様
    number_of_monster_per_party = 1 # 仕様

    possession_parties = SQL.transaction("select * from party where user_id = ? limit ?", [user_id, number_of_party_per_user])
    # ex) [{"id"=>1, "user_id"=>2, "possession_monster_id"=>4}, {"id"=>6, "user_id"=>2, "possession_monster_id"=>9}, {"id"=>8, "user_id"=>2, "possession_monster_id"=>8}]

	Validator.validate_SQL_error(possession_parties.count, is_multi_line: true)

    tmp_user_monster_storage = {}
    possession_parties.each do |row|
        party_list_template[row["id"]] = {
            row["possession_monster_id"] => nil
        }

        # 一気にwhere in したいが、どのpartyがどのmonsterと紐づいてるのかは紐づいてないといけない
        tmp_user_monster = SQL.transaction("select * from user_monster where id = ? limit 1", row["possession_monster_id"]) #{"user_id"=>2, "monster_id"=>12, "id"=>5}

        Validator.validate_SQL_error(tmp_user_monster.count, is_multi_line: false)

        tmp_user_monster_storage[row["id"]] = tmp_user_monster[0]
    end

    tmp_user_monster_storage.each do |k, v|
        monstermodel = Monster.get_specific_monster(v["monster_id"].to_i)
        tmp_user_monster_storage[k] = monstermodel
    end

    party_info = {} # partymodelのinitializeの引数　の、箱
    party_list_template.each do |party_id, party_info_hash|
        party_info_hash.each do |possession_monster_id, monster_model|
            party_info[party_id] = {}
            party_info[party_id]["id"] = party_id
            party_info[party_id]["possession_monster_id"] = possession_monster_id
            party_info[party_id]["monster_model"] = tmp_user_monster_storage[party_id]
        end

        parties_for_return[party_id] = Party.new(party_info[party_id])
    end

    SQL.close_statement()

    return parties_for_return
end


# ユーザ新規登録時のみ叩かれる
def self.init(user_id, possession_monster_id)
    sql_transaction = SQL_transaction.instance.sql

    statement = sql_transaction.prepare("insert into party(user_id, possession_monster_id) values(?,?),(?,?),(?,?)")
    result = statement.execute(user_id,possession_monster_id,user_id,possession_monster_id,user_id,possession_monster_id)
    statement.close
end


def set(user_id, possession_monster_id)
    result = SQL.transaction("select monster_id from user_monster where id = ? and user_id = ? limit 1", [possession_monster_id, user_id])

    Validator.validate_SQL_error(result.count, is_multi_line: false)

    @monster_model = Monster.get_specific_monster(result[0]["monster_id"])
    @possession_monster_id = possession_monster_id

    SQL.close_statement
end

# init時に3枠が確保され、insertは使わずupdateだけが使われる仕様
def save()
    sql_transaction = SQL_transaction.instance.sql

    statement = sql_transaction.prepare("update party set possession_monster_id = ? where id = ?")
    statement.execute(@possession_monster_id, @id)
    statement.close()
end



end