#!/usr/bin/ruby -Ku 
# -*- coding: utf-8 -*-

require 'singleton'
require 'mysql2'

class SQL_master

	include Singleton
	
	def initialize
  
		@@sql_client = Mysql2::Client.new(:socket => '/var/lib/mysql/mysql.sock', :host => 'localhost', :username => 'testwebrick', :password => 'test', :encoding => 'utf8', :database => 'master',:reconnect => true)

	end
	
	
	def sql
	
		return @@sql_client
	
	end
	
	
	def self.close
	
		if defined?(@@sql_client) then
		
			@@sql_client.close
			
		end
	
	end
	
end



