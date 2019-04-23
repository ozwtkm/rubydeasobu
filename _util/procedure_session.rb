#!/usr/bin/ruby -Ku 
# -*- coding: utf-8 -*-

require 'cgi'
require 'cgi/session'
require_relative '../exception/Error_require_login'

class Procedure_session

def self.get_session(header)

	ARGV.replace(["abc=001&def=002"]) # �I�t���C�����[�h����B
	cgi = CGI.new
	
	cgi.cookies['_session_id'] = get_session_id(header)

	session_obj = get_session_obj(cgi)

	return session_obj

end


private


def self.get_session_id(header)

		match = header.match(/(^|;\s*)session_id=([a-f0-9]+)/)
	 
		if match.nil? then
			
			raise
			
		end
	 
		return match[2]

end


def self.get_session_obj(cgi)

	# CGI::Session.new�͎��s�����ArgumentError
	# ArgErr�łȂ�����̃��O�C���G���[��f���������B
	# ��O��rescue����raise����́A�璷�ł��₾���ǂ����@��m��Ȃ�..
	begin

		session_obj = CGI::Session.new(cgi,{'new_session' => false})
	
	rescue
	
		raise Error_require_login.new
	
	end
	
	return session_obj

end


end

