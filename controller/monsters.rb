#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
require 'cgi'
require 'cgi/session'
require 'json'
require_relative '../model/user'
require_relative '../model/monster'
require_relative '../model/wallet'
require_relative './_baseclass_require_login'
require_relative '../_util/validator'

class Monsters_controller < Base_require_login

# オーバーライド。
def initialize(req,res)
	@template = "monsters.erb"

	super
end

def get_control()
	offset = @URLquery[1]
	limit = 10
	
	Validator.validate_not_Naturalnumber(offset)

	@context[:monsters] = Monster.get_possession_monsters(@user.id, limit:limit, offset:offset.to_i)
end


# todo
def post_control()
	
end

# todo
def delete_handler()

end

# todo
def put_handler()

end

# todo
def control()

end


end
