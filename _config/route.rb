#!/usr/bin/ruby -Ku 
# -*- coding: utf-8 -*-

require_relative './const'

class Routes

def self.get_routes
	filenames = Dir.glob(Environment.path_controller() + "*.rb")

	@@routes = {}

	filenames.each do |row|
		Routes.create_controller_class(row)
	end

	return @@routes
end

private

# todo adminは別処理にわけたい
def self.create_controller_class(filename)
		classname = filename.split('/').last()
		classname.slice!(".rb")

		# 「_hoge.rb」とか「huga.rb.xxx(一時ファイル)」を除去
		if classname.match(/\A[0-9a-zA-Z]+[_0-9a-zA-Z]*\z/).nil?
			return
		end
		
		require_relative '../controller/' + classname

		@@routes["/" + classname] = Object.const_get(classname.capitalize + "_controller")
end

end
