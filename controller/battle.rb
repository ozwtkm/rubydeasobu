#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'cgi'
require 'cgi/session'
require 'securerandom'
require 'json'
require_relative './_baseclass_require_login'
require_relative '../model/user'
require_relative '../model/monster'
require_relative '../model/wallet'
require_relative '../exception/Error_shortage_of_gem'


class Battle_controller < Base_require_login

def initialize(req, res)
	@template = "battle.erb"
	super
	
	@battle = Battle.get(@user.id)
end

# オーバーライド。
def get_handler()
	@context[:battle] = @battle 
	super
end


def control()
	#リクエストの想定　["1","1"]　前者：コマンド　後者：コマンド詳細	
	json = JSON.parse(@req.body)
	@command = json[0]
	@subcommand = json[1]

	@battle.advance(@command,@subcommand)

	@context[:battle] = @battle 
end

end