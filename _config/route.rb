#!/usr/bin/ruby -Ku 
# -*- coding: utf-8 -*-

require_relative './const'
require_relative '../controller/_chat'

class Routes

def self.get_routes
	filenames = Dir.glob(PATH_CONTROLLER + "*.rb")

	@@routes = {}

	filenames.each do |row|
		Routes.create_controller_class(row)
	end

	# 例外対応
	@@routes["/websocket"] = Chat

	return @@routes
end

private

# todo adminは別処理にわけたい
def self.create_controller_class(filename)
		classname = filename.split('/').last()
		classname.slice!(".rb")

		# 「_hoge.rb」とか「huga.rb.xxx(一時ファイル)」を除去
		if classname.match(/\A[0-9a-zA-Z]+_?[0-9a-zA-Z]*\z/).nil?
			return
		end
		
		require_relative '../controller/' + classname

		@@routes["/" + classname] = Object.const_get(classname.capitalize + "_controller")
end

end
