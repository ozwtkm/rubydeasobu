#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'digest/sha1'
require 'securerandom'
require_relative './_baseclass'
require_relative '../model/user'
require_relative '../model/wallet'
require_relative '../_util/procedure_session'

class User_controller < Base

def initialize(req,res)
	@template = "user.erb"

    super
end

def get_control()
    session = Procedure_session.get_session(@req.header) 

    user = User.get_user(session["id"]) # id←sessionidじゃなくてuseridね。
    
	@context[:user] = user
end

def post_control()
	json = JSON.parse(@req.body)
	@username = json[0]
	@passwd = json[1]

	query = {:ユーザ名 => @username, :パスワード => @passwd}

	exceptions = []
	query.each do |key,value|
		begin
			Validator.validate_nil(key, value)
			Validator.validate_special_character(key, value)
		rescue => e
			exceptions << e
		end
	end

	if !exceptions.empty?
		raise Error_multi_412.new(exceptions)
	end
	
	user = regist()

	@context[:user] = user
end


def regist()
	user = User.add_user(@username, @passwd)
	
	Wallet.init(user.id)
	initial_monster = Monster.init(user.id)
	Party.init(user.id, initial_monster)

	return user
end


end

