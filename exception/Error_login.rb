#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require_relative './baseclass_exception'

class Error_login < Base_exception

def initialize()

	super(412, "IDかパスワードが違う")

end

end