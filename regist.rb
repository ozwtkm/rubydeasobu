#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require "pry"
require 'digest/sha1'
require 'securerandom'
require_relative './baseclass'


class Regist < Base


def get_handler()

	view()
	
end


def post_handler()

	control()
	view()
	
end


def control()


		# 何はともあれまずは入力値検証
		begin
			
			validate_special_character({:ユーザ名 => @req.query["name"], :パスワード => @req.query["passwd"]})
			
		rescue => e
		
			@context[:msg] = ""

			e.falselist.each do |row|
			
				@context[:msg] += "#{row}は/\A[a-zA-Z0-9_@]+\z/でよろ<br>"
			
			end
			
			return
			
		end

		
		begin
		
			check_id_duplication(@req.query["name"], @req.query["passwd"])
		
		rescue => e
		
			@context[:msg] = "キャラかぶってるで"

			return

		end


		regist(@req.query["name"], @req.query["passwd"])
		
		@context[:msg] = "#{@req.query["name"]}を登録したったで。"

end











def check_id_duplication(username, passwd)

	# ユーザIDを重複チェック
	# DB側でunique制約しないとレースコンディションの可能性あり
	statement = @sql.prepare("select * from users2 where name = ? limit 1")
	result_tmp = statement.execute(username)
	
	result =nil
	result_tmp.each do |row|
	
		result = row
		
	end
	
	if result != nil
	
		raise
	
	end

end


def regist(username, passwd)

	# saltを生成
	salt = SecureRandom.hex(10) + "aaaaburiburi"
		
	# saltとパスワードを連結してハッシュ値生成
	pw_hash = Digest::SHA1.hexdigest(passwd+salt)
		
	statement = @sql.prepare("insert into users2(name,salt,passwd) values(?,?,?)")
	statement.execute(username, salt, pw_hash)

end


# オーバーライド
def view_http_body()

	@res.body = render("regist.erb", @context)

end


end
