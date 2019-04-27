#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require_relative './baseclass_exception'

class Error_over_count < Base_exception

def initialize()

	super(412, "いっぱい取れちゃったんですがそれは")

end

end