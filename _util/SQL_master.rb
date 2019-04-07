#!/usr/bin/ruby -Ku 
# -*- coding: utf-8 -*-

require 'singleton'
require 'mysql2'

class SQL_master
attr_reader :sql

	include Singleton
	
	def initialize
  
		@sql = Mysql2::Client.new(:socket => '/var/lib/mysql/mysql.sock', :host => 'localhost', :username => 'testwebrick', :password => 'test', :encoding => 'utf8', :database => 'master')

	end
	
end



