#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'digest/sha1'
require 'securerandom'
require_relative './baseclass'
require_relative '../model/user'
require_relative '../model/wallet'
require_relative '../exception/Error_duplicate_id'

class Regist < Base

def initialize(req,res)

	@template = "regist.erb"

	super

end


def control()

	query = {:ユーザ名 => @req.query["name"], :パスワード => @req.query["passwd"]}

	exceptions = []
		
	query.each do |key,value|

		begin
		
			validate_nil(key, value)
			validate_special_character(key, value)
		
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

	# rescueしてraiseするのなんか気持ち悪いがほかにmodelでのエラーを拾うやり方がわからない
	begin
	
		user = User.add_user(username, passwd)

	rescue
	
		raise Error_duplicate_id.new

	end

	Wallet.initialize_wallet(user.id)

	return user

end


end

