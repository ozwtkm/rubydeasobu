#!/usr/bin/ruby -Ku 
# -*- coding: utf-8 -*-

class Base

def render(template)

	# 単純に「context」だと長いから代入して変数名を短くしてるだけ。
	c = @context
	erb = ERB.new(File.read(Environment.path_view() + template))
	return erb.result(binding)
	
end

end


