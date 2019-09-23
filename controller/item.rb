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

# オーバーライド
def view_http_header()
	@res.header['Content-Type'] = "application/json; charset=UTF-8"
end

def get_handler()
	offset = @URLquery[1]
	limit = 10
	
	Validator.validate_not_Naturalnumber(offset)

	@context[:item] = Item.get_possession_items(@user.id, limit:limit, offset:offset.to_i)

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