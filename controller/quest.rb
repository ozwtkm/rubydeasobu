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

	validate_input() # これbaseclassに引っ越した方が良さそう
end

# クエストの開始
def post_control()
	# [partnerid,partyid,questid]という形でくる
	partner_monster_id = @json[0]
	party_id = @json[1]
	dangeon_id = @json[2]

	quest = Quest.start(@user.id, partner_monster_id, party_id, dangeon_id)
	
	@context[:quest] = quest

	@res.status = CREATED
end


# クエストの更新。[[0-3]]みたいなの受け取って座標移動処理。必要に応じてイベント処理。
def put_control()
	#リクエストの想定　[1,1]　[行動種類, 行動内容] みたいな	
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


def validate_input()
	case @req.request_method
	when "GET"
		# 何もしない
	when "POST"
		begin
			@json = JSON.parse(@req.body)
			
			raise if @json.class != Array || @json.count != 3
		rescue
			raise "JSON形式(3要素の配列)でよろ"
		end

		@json.each { |x| Validator.validate_not_Naturalnumber(x) }
	when "PUT"
		begin
			@json = JSON.parse(@req.body)
			
			raise if @json.class != Array || @json.count != 2
		rescue
			raise "JSON形式(2要素の配列)でよろ"
		end

		@json.each { |x| Validator.validate_not_Naturalnumber_and_not_0(x) }
	when "DELETE"
		# 何もしない
	end
end

end