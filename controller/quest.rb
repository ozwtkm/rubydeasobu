#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'json'
require_relative './_baseclass_require_login'
require_relative '../model/quest'


class Quest_controller < Base_require_login
UP = 0
RIGHT = 1
DOWN = 2
LEFT = 3

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
	#リクエストの想定　[134,132,1]　party id , partner_id , dangeon id	
	@json = JSON.parse(@req.body)

	check_post_json()

	party_id = @json[0].to_i
    quest_id = @json[1].to_i

	@quest = Quest.start(@user.id, party_id, quest_id)
	
	@context[:quest] = @quest
end


# クエストの更新。[[0-3]]みたいなの受け取って座標移動処理。必要に応じてイベント処理。
def put_control()
	#リクエストの想定　[1,1]　前者：コマンド　後者：コマンド詳細	
	@json = JSON.parse(@req.body)
	check_put_json()
end

def check_put_json()
	if !@json.all?{|x| (UP..LEFT).to_a.include?(x)}
		raise "0-3でよろ" 
	end
end

def check_post_json()
	if !@json.all?{|x| (1..Float::INFINITY).to_a.include?(x)}
		raise "自然数でよろ" 
	end
end


end