#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require_relative './baseclass_exception'

class Error_require_login < Base_exception

def initialize()

	super(401, "ログインしてこいゴミ")

end

end