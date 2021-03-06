#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
require 'cgi'
require 'cgi/session'
require 'json'
require_relative '../model/item'
require_relative './_baseclass_require_login'
require_relative '../_util/validator'

class Item_controller < Base_require_login

# オーバーライド。
def initialize(req,res)
	@template = "item.erb"

	super
end

def get_control()
	offset = @URLquery[1]
	limit = 10
	
	Validator.validate_not_Naturalnumber_and_not_0(offset.to_i)

	@context[:item] = Item.get_possession_items(@user.id, limit:limit, offset:offset.to_i)
end

end
