#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'json'
require_relative './_baseclass_require_login'
require_relative '../model/quest'

class Quest_controller < Base_require_login
CREATED = 201
RESET_CONTENT = 205

def initialize(req, res)
	@template = "quest.erb"

	super
end


# オーバーライド
def view_http_header()
	@res.header['Content-Type'] = "application/json; charset=UTF-8"
end

# クエストの開始
def control()
	#リクエストの想定　[134,132,1]　partner_id , party id , dangeon id	
	@json = JSON.parse(@req.body)

	check_json()

	partner_monster_id = @json[0]
	party_id = @json[1]
	quest_id = @json[2]

	quest = Quest.start(@user.id, partner_monster_id, party_id, quest_id)
	
	@context[:quest] = quest

	@res.status = CREATED
end


# クエストの更新。[[0-3]]みたいなの受け取って座標移動処理。必要に応じてイベント処理。
def put_control()
	#リクエストの想定　[1,1]　[行動種類, 行動内容] みたいな	
	@json = JSON.parse(@req.body)

	check_json()

	action_kind = @json[0]
	action_value = @json[1]

	quest = Quest.get(@user.id)
	quest.advance(action_kind, action_value)

	@context[:quest] = quest

	@res.status = CREATED
end

# キャンセル用。battleなど依存関係あるもの諸々消す
def delete_control()
	quest = Quest.get(@user.id)

	quest.cancel()

	@context[:quest] = quest

	@res.status = RESET_CONTENT
end

def check_json()
	if !@json.all?{|x| (0..Float::INFINITY).include?(x)}
		raise "0か自然数でよろ" 
	end
end

end