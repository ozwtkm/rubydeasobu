#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'digest/sha1'
require 'securerandom'
require_relative '../baseclass'
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
		
			check_id_duplication(@req.query["name"], @req.query["passwd"])
		
		rescue => e
		
			@context[:msg] << "キャラかぶってるで"

			return

		end


		@user.regist(@sql, @req.query["name"], @req.query["passwd"])
		
		@context[:msg] << "#{@req.query["name"]}を登録したったで。"

end



def check_id_duplication(username, passwd)

	# ユーザIDを重複チェック
	# DB側でunique制約しないとレースコンディションの可能性あり
	statement = @sql.prepare("select * from users2 where name = ? limit 1")
	result_tmp = statement.execute(username)

	if result_tmp.count == 1

		raise
	
	end

end



end
