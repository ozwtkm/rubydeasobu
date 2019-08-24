#!/usr/bin/ruby -Ku 
# -*- coding: utf-8 -*-
require 'singleton'
require 'mysql2'
require_relative '../_config/const'

class SQL_master
	include Singleton
	
	def initialize
		database = "master"
		if Environment.dev()
			database = "dev_master"
		end

		socket = Environment.sql_socket()
		host = Environment.sql_host()
		username = Environment.sql_user()
		password = Environment.sql_password()

		@@sql_client = Mysql2::Client.new(:socket => socket, :host => host, :username => username, :password => password, :encoding => 'utf8', :database => database,:reconnect => true)
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



