#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require_relative './baseclass_exception'

class Error_not_naturalnumber < Base_exception

def initialize(key)

	super(412, "#{key}は(/\A[0-9]+\z/)で頼む") #0が自然数に含まれるかは公理に依るが..

end

end
