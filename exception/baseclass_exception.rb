#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

class Base_exception < StandardError
attr_reader :status, :message

def initialize(status = 412, message = nil)

	@status = status
	@message = message

end

end