#!/usr/bin/ruby -Ku 
# -*- coding: utf-8 -*-
require 'singleton'
require 'mysql2'
require_relative '../_config/const'

class SQL_transaction
	include Singleton
	
	def initialize
		database = "transaction"
		if Environment.dev?
			database = "dev_transaction"
		end

		@@sql_client = Mysql2::Client.new(:socket => SQL_SOCKET, :host => SQL_HOST, :username => SQL_USER, :password => SQL_PASSWORD, :encoding => 'utf8', :database => database, :reconnect => true)
		@@sql_client.query("begin")
	end
	
	def sql
		return @@sql_client
	end
	
	def self.commit
		if defined?(@@sql_client) then
			@@sql_client.query("commit")
		end
	end
	
	def self.close
		if defined?(@@sql_client) then
			@@sql_client.close
		end
	end
	
end