#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require_relative './baseclass_exception'

class Error_multi_412 < Base_exception
attr_reader :exceptions

def initialize(exceptions)
	super(412)

	@exceptions = exceptions
end

end
