#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
require_relative './_baseclass_require_login'

class Mypage_controller < Base_require_login

def initialize(req,res)
	@template = "mypage.erb"

	super
end

end