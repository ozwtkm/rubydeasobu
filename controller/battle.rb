#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'json'
require_relative './_baseclass_require_login'


class Battle_controller < Base_require_login

def initialize(req, res)
	@template = "battle.erb"
	super
	
	@battle = Battle.get(@user.id)
	@context[:battle] = @battle

	validate_input() # これbaseclassに引っ越した方が良さそう
end

# startするときはquestから叩かれるから、UIから叩かれるのはput（コマンド送って戦闘を進める）だけ
def put_control()
	#リクエストの想定　[1,1]　前者：コマンド　後者：コマンド詳細	
	command = @json[0].to_i
	subcommand = @json[1].to_i

	@battle.advance(command, subcommand)

	@context[:battle] = @battle
end



def validate_input()
	case @req.request_method
	when "GET"
	when "POST"
	when "PUT"
		begin
			@json = JSON.parse(@req.body)
			
			raise if @json.class != Array || @json.count != 2
		rescue
			raise "JSON形式(2要素の配列)でよろ"
		end

		@json.each { |x| Validator.validate_not_Naturalnumber_and_not_0(x) }
	when "DELETE"
	end
end

end