#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'digest/sha1'
require 'securerandom'
require_relative './_baseclass'
require_relative '../model/user'
require_relative '../model/wallet'

class Regist_controller < Base

def initialize(req,res)

	@template = "regist.erb"

	super

end


def control()

	query = {:ユーザ名 => @req.query["name"], :パスワード => @req.query["passwd"]}

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
	
	user = regist(@req.query["name"], @req.query["passwd"])

	@context[:user] = user

end


def regist(username, passwd)

	user = User.add_user(username, passwd)
	
	Wallet.init(user.id)

	return user

end


end

