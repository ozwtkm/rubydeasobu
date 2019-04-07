#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'cgi'
require 'cgi/session'
require 'json'
require_relative './baseclass'
require_relative '../model/user'
require_relative '../model/monster'
require_relative '../model/wallet'
require_relative './baseclass_require_login'

class Monsters < Base_require_login

# オーバーライド。
def initialize(req,res)

	@template = "json.erb"

	super
	
	@context[:json] = []
	
end


# オーバーライド
def view_http_header()

	@res.header['Content-Type'] = "application/json; charset=UTF-8"

end


def get_handler()
	
	super
	
	@monsters = Monster.get_possession_monsters(@user.id)
	
	@monsters.each do |row|
	
		@context[:json] << {:name => row.name, :rarity => row.rarity}
	
	end
	
	@context[:json] = JSON.generate(@context[:json])

end


# todo
def post_handler()

	super

end

# todo
def delete_handler()

	super

end


# todo
def put_handler()

	super

end


def control()

	

end



end
