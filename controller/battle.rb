#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'json'
require_relative './_baseclass_require_login'


class Battle_controller < Base_require_login

def initialize(req, res)
	@template = "battle.erb"
	super
	
	@battle = Battle.get(@user.id)
end

# startするときはquestから叩かれるから、UIから叩かれるのはput（コマンド送って戦闘を進める）だけ
def put_handler()
	#リクエストの想定　[1,1]　前者：コマンド　後者：コマンド詳細	
	@json = JSON.parse(@req.body)
	check_input_json()

	@command = json[0].to_i
	@subcommand = json[1].to_i

	@battle.advance(@command,@subcommand)

	@context[:battle] = @battle
end

def check_input_json()
	if !@json.all?{|x| (1..9).to_a.include?(x)}
		raise 
	end
end


end