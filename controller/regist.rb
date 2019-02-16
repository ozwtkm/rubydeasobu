#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'digest/sha1'
require 'securerandom'
require_relative './baseclass'
require_relative '../model/user'

class Regist < Base

def initialize(req,res)

	@template = "regist.erb"

	super
	
	@context[:msg] = []
	
	@user = User.new

end


def control()

		# 何はともあれまずは入力値検証
		begin
			
			validate_special_character({:ユーザ名 => @req.query["name"], :パスワード => @req.query["passwd"]})
			
		rescue => e

			e.falselist.each do |row|
			
				@context[:msg] << "#{row}は/\A[a-zA-Z0-9_@]+\z/でよろ"
			
			end
			
			return
			
		end

		
		begin
			
			@user.regist(@sql, @req.query["name"], @req.query["passwd"])
		
		rescue => e
		
			@context[:msg] << "キャラかぶってるで"

			return

		end
		
		@context[:msg] << "#{@req.query["name"]}を登録したったで。"

end


end
