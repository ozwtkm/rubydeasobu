#!/usr/bin/ruby -Ku 
# -*- coding: utf-8 -*-

require 'cgi'
require 'cgi/session'


class Procedure_session

def self.get_session(cgi, header)
	
	cgi.cookies['_session_id'] = get_session_id(header)
	
	session_obj = get_session_obj(cgi)
	
	return session_obj

end


private


def self.get_session_id(header)

	match = header.match(/session_id=([a-f0-9]+)/)
	
	if match.nil? then
		
		raise
		
	end
 
	return match[1]

end


def self.get_session_obj(cgi)

	session_obj = CGI::Session.new(cgi,{'new_session' => false})
	
	return session_obj

end



end

