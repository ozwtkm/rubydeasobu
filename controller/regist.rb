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

end


def control()

	query = {:ユーザ名 => @req.query["name"], :パスワード => @req.query["passwd"]}
	error_flg = false

	begin
		
		validate_nil(query)
		
	rescue => e

		e.falselist.each do |row|
			
			@context[:msg] << "#{row}をちゃんと指定しろ。"
			
			query.delete(row)
			
		end

		error_flg = true

	end
	
	
	begin
		
		validate_special_character(query)

	rescue => e

		e.falselist.each do |row|
			
			@context[:msg] << "#{row}は/\A[a-zA-Z0-9_@]+\z/でよろ"
			
		end

		error_flg = true

	end

	# なんかキモくて嫌だが、以下の用件を満たす方法がerror_flgを用いる方法しか思いつかなかった。
	# ・クエリの片方がnilチェック、片方が特殊文字チェックで引っかかるとき、両方のエラーを伝えたい。

	if error_flg then
	
		return
	
	end

		
	begin
	
		User.regist(@req.query["name"], @req.query["passwd"])
	
	rescue => e
	
		@context[:msg] << "キャラかぶってるで"

		return

	end
	
	@context[:msg] << "#{@req.query["name"]}を登録したったで。"

end


end
