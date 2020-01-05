#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require_relative '../_util/SQL_master'
require_relative '../_util/SQL_transaction'
require_relative './basemodel'
require_relative '../_util/documentDB'
require_relative '../_util/validator'
require_relative './battle'
require_relative './item'
require_relative './equipment'
require_relative './map'
require_relative './monster'
require_relative '../_util/cache'
require 'securerandom'



class Quest < Base_model
attr_accessor :dangeon_info, :team_info, :current_x, :current_y, :current_z, :situation, :object
attr_reader :user_id

# 初期プレイヤ座標
INITIAL_X = 0
INITIAL_Y = 0
INITIAL_Z = 1

# situationとaction_kind管理用
WALKING = 0
ITEM = 1
STEP = 2
GOAL = 3
POT = 4
BATTLE = 5
FINISHED = 6
CANCELED = 7

# action_value 管理用
UP = 1
LEFT = 2
DOWN = 4
RIGHT = 8

YES = 0
NO = 1

# acquisition用
ACQUIRED = 1
DISCARDED = 2
DONE = 3

# appearance_placeの名前解決用。こういうの用のmasterファイル作っておきたい。
TYPE_MONSTER = 1
TYPE_ITEM = 2
TYPE_EQUIPMENT = 3

# equipmentのkindの名前解決用。
KIND_STEP = 1
KIND_GOAL = 2
KIND_POT = 3

def initialize(user_id,dangeon_info,team_info,current_x,current_y,current_z)
    @user_id = user_id

    @dangeon_info = dangeon_info
    @team_info = team_info

    @current_x = current_x
    @current_y = current_y
    @current_z = current_z

    @situation = WALKING
    @object = nil # 今プレイヤがいる位置に何があるかをクライアントに教える用. itemmodelのインスタンスとか
end


def self.start(user_id, partner_id, party_id, dangeon_id)
    Quest.check_start_condition(user_id, partner_id, party_id, dangeon_id)

    sql_transaction = SQL_transaction.instance.sql

    dangeon_info = {}
    dangeon_info["id"] = dangeon_id
    dangeon_info["map"] = Map.get(dangeon_id, INITIAL_Z)

    team_info = {}
    team_info["party"] = party_id
    team_info["partner"] = partner_id

    statement = sql_transaction.prepare("insert into quest(user_id,dangeon_id,current_x,current_y,current_z,party_id,partner_monster,obtain_money) values(?,?,?,?,?,?,?,?)")
    result = statement.execute(user_id, dangeon_id, INITIAL_X, INITIAL_Y, INITIAL_Z, party_id, partner_id, 0)

    statement.close()

    quest = Quest.new(user_id, dangeon_info, team_info, INITIAL_X, INITIAL_Y, INITIAL_Z)

    return quest
end


def self.get(user_id)
    sql_transaction = SQL_transaction.instance.sql
	sql_master = SQL_master.instance.sql

    statement = sql_transaction.prepare("select * from quest where user_id = ? limit 1")
    result = statement.execute(user_id)

    Validator.validate_SQL_error(result.count, is_multi_line: false)

    x = result.first["current_x"]
    y = result.first["current_y"]
    z = result.first["current_z"]

    dangeon_info = {}
    dangeon_info["id"] = result.first["dangeon_id"]
    dangeon_info["map"] = Map.get(result.first["dangeon_id"], z)

    team_info = {}
    team_info["party"] = result.first["party_id"]
    team_info["partner"] = result.first["partner_monster"]

    statement.close()
    
    quest = Quest.new(user_id, dangeon_info, team_info, x, y, z)

    return quest
end


def self.check_start_condition(user_id, partner_id, party_id, dangeon_id)
    sql_transaction = SQL_transaction.instance.sql
	sql_master = SQL_master.instance.sql

    statement = sql_transaction.prepare("select * from quest where user_id = ? limit 1")
    result = statement.execute(user_id)

    if result.count >= 1
        raise "既に別クエスト実施中"
    end

    partner_candidate_list = Quest.create_partner_candidate(user_id)
    
    if !partner_candidate_list.any?{|x| x === partner_id}
        raise "そいつは連れていけない"
    end

    # 追々はcondidate_dangeonみたいなテーブルで検証（進行するごとに増えてく
    statement = sql_master.prepare("select * from dangeons where id = ? limit 1")
    result = statement.execute(dangeon_id)

    Validator.validate_SQL_error(result.count, is_multi_line: false)
   

    statement = sql_transaction.prepare("select * from party where id = ? and user_id = ? limit 1")
    result = statement.execute(party_id, user_id)

    Validator.validate_SQL_error(result.count, is_multi_line: false)

    statement.close()
end



def advance(action_kind, action_value)
    case action_kind
    when WALKING
        handler = Quest::Walking_action_handler.new(self)
    when ITEM
        handler = Quest::Item_action_handler.new(self)
    when STEP
        handler = Quest::Step_action_handler.new(self)
        # 追々実装。
        # x,y,z -> 0,0,z+1 にする。
    when GOAL
        handler = Quest::Goal_action_handler.new(self)
    when POT
        handler = Quest::Pot_action_handler.new(self)
        # 追々。
        # とりあえずacquisitionをDONEにしておき、クエスト終了時にvalueのitemをinsert候補に加える。
    else
        raise "は？"
    end

    handler.handle_action(action_value)
end



class Base_action_handler
    def initialize(quest)
        @quest = quest
    end

    def handle_action(action_value)
        validate_timing()
        do_action(action_value)
    end

    private

    def validate_timing()
        raise NotimplementError
    end

    def do_action(action_value)
        raise NotimplementError
    end
end


class Walking_action_handler < Base_action_handler
    def validate_timing()
        result = SQL.transaction("select * from battle where user_id = ? limit 1", @quest.user_id)
        
        if result.count != 0
            raise "バトルしろチキンが"
        end

        SQL.close_statement()
    end

    def do_action(action_value)
        @quest.validate_wall(action_value)

        case action_value
        when UP
            @quest.current_y -= 1
        when RIGHT
            @quest.current_x += 1
        when DOWN
            @quest.current_y += 1
        when LEFT
            @quest.current_x -= 1
        end

        @quest.save() # handle_eventの前にsaveしとかないとバトル開始がうまく行かない

        @quest.handle_event()
    end
end


class Item_action_handler < Base_action_handler
    # validate_timingで取得したitemplaceidを再利用したいためオーバーライドしてる
    def handle_action(action_value)
        item_place_id = validate_timing()
        do_action(action_value, item_place_id)
    end

    def validate_timing()
        result = SQL.master("select * from appearance_place where dangeon_id =? and x = ? and y = ? and z = ? limit 1",[@quest.dangeon_info["id"], @quest.current_x, @quest.current_y, @quest.current_z])

        if result.count === 0 || result[0]["type"] != TYPE_ITEM
            raise "そこアイテム無いよ"
        end

        item_place_id = result[0]["id"]

        result = SQL.transaction("select * from quest_acquisition where user_id = ? and appearance_id = ? limit 1", [@quest.user_id, item_place_id])

        if result.count >= 1
            raise "もう捨てたか取ったかしてるよ"
        end

        SQL.close_statement()

        return item_place_id
    end

    def do_action(action_value, item_place_id)
        case action_value
        when YES
            status = ACQUIRED
        when NO
            status = DISCARDED
        else
            raise "何しようとしトンねん、、"
        end

        SQL.transaction("insert into quest_acquisition(user_id,appearance_id,status) values(?,?,?)", [@quest.user_id, item_place_id, status])
        SQL.close_statement()
    end
end



class Step_action_handler < Base_action_handler
    # todo
end

class Goal_action_handler < Base_action_handler
    def validate_timing()
        result = SQL.master("select * from appearance_place where dangeon_id = ? and x = ? and y = ? and z = ? limit 1", [@quest.dangeon_info["id"], @quest.current_x, @quest.current_y, @quest.current_z])
    
        if result.count === 0 || result[0]["type"] != TYPE_EQUIPMENT
            raise "そこ装置無いよ"
        end

        @quest.object = Equipment.get_specific_equipment(result[0]["appearance_id"])

        if @quest.object.kind != KIND_GOAL
            raise "そこゴール無いよ"
        end

        SQL.close_statement()
    end

    def do_action(action_value)
        case action_value
        when YES
            @quest.finish()
        when NO
            # スルーするのと一緒なので特に何も起こらない。
        end
    end
end

class Pot_action_handler < Base_action_handler
    # todo
end


def validate_wall(direction)
    case direction
    when UP
        if @current_y-1 < 0 || @dangeon_info["map"].rooms[@current_y-1][@current_x].nil?
            raise "そこに部屋は無い"
        end
    when LEFT
        if @dangeon_info["map"].rooms[@current_y][@current_x-1].nil? || @current_x-1 < 0
            raise "そこに部屋は無い"
        end
    when DOWN
        if @dangeon_info["map"].rooms[@current_y+1].nil? || @dangeon_info["map"].rooms[@current_y+1][@current_x].nil?
            raise "そこに部屋は無い"
        end
    when RIGHT
        if @dangeon_info["map"].rooms[@current_y][@current_x+1].nil?
            raise "そこに部屋は無い"
        end
    else
        raise "どこ行こうとしてんねん,,,"
    end

    if !@dangeon_info["map"].rooms[@current_y][@current_x].aisle[direction]
        raise "そこは壁" 
    end
end


def handle_event()
    sql_master = SQL_master.instance.sql
    sql_transaction = SQL_transaction.instance.sql

    statement = sql_master.prepare("select * from appearance_place where dangeon_id = ? and x = ? and y = ? and z = ? limit 1")
    result = statement.execute(@dangeon_info["id"], @current_x, @current_y, @current_z)

    if result.count === 0
        return
    end

    case result.first["type"]
    when TYPE_MONSTER

        quest_acquisition = SQL.transaction("select * from quest_acquisition where user_id = ? and appearance_id = ? limit 1", [@user_id, result.first()["id"]])

        if quest_acquisition.count >= 1 # イベント消化済みかの確認
            return
        end
        
        SQL.transaction("insert into quest_acquisition(user_id, appearance_id, status) values(?,?,?)", [@user_id, result.first()["id"], DONE])

        @situation = BATTLE
        @object = Monster.get_specific_monster(result.first()["appearance_id"])
        
        player_monster = SQL.transaction("select * from party where id = ?", @team_info["party"])
        Validator.validate_SQL_error(player_monster.count, is_multi_line: false)
        player_monster_possession_id = player_monster[0]["possession_monster_id"]
        player_monster_correspondence = SQL.transaction("select * from user_monster where id = ?", player_monster_possession_id)
        Validator.validate_SQL_error(player_monster_correspondence.count, is_multi_line: false)

        player_monster_id = player_monster_correspondence[0]["monster_id"]
        partner_monster_id = @team_info["partner"]
        enemy_monster_id = @object.id

        Battle.start(@user_id, player_monster_id, partner_monster_id, enemy_monster_id)

        SQL.close_statement()
    when TYPE_ITEM

        statement2 = sql_transaction.prepare("select * from quest_acquisition where user_id = ? and appearance_id = ? limit 1")
        result2 = statement2.execute(@user_id, result.first()["id"])

        if result2.count >= 1
            return
        end

        @situation = ITEM
        @object = Item.get_specific_item(result.first["appearance_id"])

        statement2.close()

    when TYPE_EQUIPMENT

        statement2 = sql_transaction.prepare("select * from quest_acquisition where user_id = ? and appearance_id = ? limit 1")
        result2 = statement2.execute(@user_id, result.first()["id"])

        if result2.count >= 1
            return
        end

        @object = Equipment.get_specific_equipment(result.first["appearance_id"])

        case @object.kind
        when KIND_STEP
            @situation = STEP
        when KIND_GOAL
            @situation = GOAL
        when KIND_POT
            @situation = POT
        end

        statement2.close()

    end

    statement.close()
end



def finish()
    # item処置。　itemのうちkindがmoneyになっているものはobtain_moneyへの変換を忘れずに。

    sql_master = SQL_master.instance.sql
    sql_transaction = SQL_transaction.instance.sql

    statement = sql_transaction.prepare("select * from quest_acquisition where user_id = ? and status = ?")
    result = statement.execute(@user_id, ACQUIRED)

    if result.count != 0
        item_place_ids = []
        statement_candidate = "?"
        result.each_with_index do |row, i|
            if i != 0
                statement_candidate += " or ?"
            end

            item_place_ids << row["appearance_id"]
        end

        statement2 = sql_master.prepare("select * from appearance_place where id = " + statement_candidate)
        result2 = statement2.execute(*item_place_ids)

        # To do：　獲得アイテムのうち種類がmoneyのもの → obtain_money の変換。

        statement_values = "values(?,?,?)"
        query_values = []
        result2.each_with_index do |row, i|
            if i != 0
                statement_values += ", (?,?,?)"
            end

            query_values << @user_id
            query_values << row["appearance_id"]
            query_values << 1
        end

        statement3 = sql_transaction.prepare("insert into user_item(user_id, item_id, quantity) " + statement_values + " on duplicate key update quantity = quantity + values(quantity)")
        result3 = statement3.execute(*query_values)

        statement2.close()
        statement3.close()

    end

    statement4 = sql_transaction.prepare("select * from quest where user_id = ? limit 1")
    result4 = statement4.execute(@user_id)

    statement5 = sql_transaction.prepare("update wallets set money = money + ? where user_id = ? limit 1")
    statement5.execute(result4.first["obtain_money"], @user_id)

    statement6 = sql_transaction.prepare("delete from quest where user_id = ? limit 1")
    statement6.execute(@user_id)

    statement7 = sql_transaction.prepare("delete from quest_acquisition where user_id = ?")
    statement7.execute(@user_id)
    
    @situation = FINISHED

    statement.close()
    statement4.close()
    statement5.close()
    statement6.close()
    statement7.close()
end


# deleteメソッドで呼ばれる用。
def cancel()
    SQL.transaction("delete from quest where user_id = ?", @user_id)
    SQL.transaction("delete from quest_acquisition where user_id = ?", @user_id)

    if Battle.exist?(@user_id)
        battle = Battle.get(@user_id)
        battle.close_battle()
    end

    @situation = CANCELED

    SQL.close_statement()
end


# フレンドが実装されたらフレンドリストから取得する様にする
def self.create_partner_candidate(user_id)
    partner_candidate_list = Cache.instance.get(user_id.to_s + 'partner_candidate_list')
    # コントローラで記号は弾かれてるのでinjectionはできない

	if !partner_candidate_list.nil?
		Log.log("cacheありなのでキャッシュからpartner_candidate_list取得した")
		return partner_candidate_list
    end

    sql_transaction = SQL_transaction.instance.sql

    # これは良くない気がするが、最大値を知らないと乱数でのwhere in時に取得され得ないレコードが発生しうる
    statement = sql_transaction.prepare("select max(user_id) from partner_candidate")
    result = statement.execute()

    max = result.first["max(user_id)"]
    
    partner_candidate_list = []
    number_of_candidate = 5 # 仕様で決められてるパートナー候補数。
    number_of_random = 50 # 50は適当
    generated_random = [] # wherein済なものを省くための履歴
    randoms_for_wherein = [] # select文に渡す配列

    loop do
        number_of_random.times do
            randoms_for_wherein << SecureRandom.random_number(max) + 1
        end

        randoms_for_wherein -= generated_random
        generated_random += randoms_for_wherein

        partner_candidate_list += get_partner_candidate(number_of_candidate, randoms_for_wherein)

        if partner_candidate_list.count === number_of_candidate
            break
        end

        number_of_candidate -= partner_candidate_list.count
    end

    Cache.instance.set(user_id.to_s + 'partner_candidate_list', partner_candidate_list)

	Log.log("cacheなしなのでpartner_candidate_listセットした")

    return partner_candidate_list
end


def self.get_partner_candidate(number_of_candidate, randoms_for_wherein)
    sql_transaction = SQL_transaction.instance.sql

    query = "select * from partner_candidate where user_id in ("
    number_of_random = randoms_for_wherein.count
    candidate_array_for_return = []

    number_of_random.times do |i|
        i+1 === number_of_random ? query+="?" : query+="?,"
    end

    query += ") limit "
    query += number_of_random.to_s

    statement = sql_transaction.prepare(query)
    result = statement.execute(*randoms_for_wherein)

    result.each_with_index do |row, i|
        candidate_array_for_return << row["monster_id"] unless row["monster_id"].nil?
        break if i+1 === number_of_candidate
    end

    statement.close()

    candidate_array_for_return
end



def save()
    sql_transaction = SQL_transaction.instance.sql

    statement = sql_transaction.prepare("update quest set current_x = ?, current_y = ?, current_z = ? where user_id = ?")
    statement.execute(@current_x, @current_y, @current_z, @user_id)

    statement.close()
end


# debug用
def self.debug_reset_quest()
    sql_transaction = SQL_transaction.instance.sql
	sql_master = SQL_master.instance.sql

    statement = sql_transaction.prepare("delete from quest")
    statement.execute()

    statement.close()

    Log.log("Quest is reseted")
end

end