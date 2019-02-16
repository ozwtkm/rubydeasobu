#!/usr/bin/ruby -Ku 
# -*- coding: utf-8 -*-

require_relative '../_config/const'

class Base

def render(template)

	# 単純に「context」だと長いから代入して変数名を短くしてるだけ。
	c = @context
	erb = ERB.new(File.read(PATH + template))
	return erb.result(binding)
	
end

end


