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

# オーバーライド
def view_http_header()
	@res.header['Content-Type'] = "application/json; charset=UTF-8"
end

def get_handler()
	offset = @URLquery[1]
	
	Validator.validate_not_Naturalnumber(offset)

	@context[:monsters] = Monster.get_possession_monsters(@user.id, 10, offset.to_i)

	super
end


# todo
def post_handler()
	super
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
