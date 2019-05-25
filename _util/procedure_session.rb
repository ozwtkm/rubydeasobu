#!/usr/bin/ruby -Ku 
# -*- coding: utf-8 -*-
require 'cgi'
require 'cgi/session'
require_relative '../exception/Error_require_login'

class Procedure_session

def self.get_session(header)
	if header["cookie"][0].nil? # Webrickの仕様的にheader["cookie"].classがArray
		raise Error_require_login.new
	end
	
	ARGV.replace(["abc=001&def=002"]) # オフラインモード回避。
	cgi = CGI.new
	
	cgi.cookies['_session_id'] = get_session_id(header["cookie"][0])

	session_obj = get_session_obj(cgi)

	return session_obj
end

private

def self.get_session_id(header)
		match = header.match(/(^|;\s*)session_id=([a-f0-9]+)/)
		if match.nil? then
			raise Error_require_login.new
		end
		
		return match[2]
end

def self.get_session_obj(cgi)

	# CGI::Session.newは失敗するとArgumentError
	# ArgErrでなく自作のログインエラーを吐かせたい。
	# 例外をrescueしてまたraiseするの、冗長でいやだがこれで正解なのか？
	begin
		session_obj = CGI::Session.new(cgi,{'new_session' => false})
	rescue
		raise Error_require_login.new
	end
	
	return session_obj
end

end

