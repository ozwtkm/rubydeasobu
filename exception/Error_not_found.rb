#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require_relative './baseclass_exception'

class Error_not_found < Base_exception

def initialize()

	super(404, "データちゃんと取ってこれなかった")

end

end