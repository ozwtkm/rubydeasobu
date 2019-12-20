#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
require 'json'
require_relative '../model/party'
require_relative './_baseclass_require_login'
require_relative '../_util/validator'

class Party_controller < Base_require_login
CREATED = 201

# オーバーライド。
def initialize(req,res)
	@template = "party.erb"

    super

	@parties = Party.get(@user.id)

    validate_input() # あとでbaseclassに引っ越し
end

def get_control()
    @context[:parties] = @parties
end

# ユーザ作成時にinitされるので叩かれない想定。
def post_handler()
	super
end

# 枠3固定仕様なので叩かれない想定。
def delete_handler()
    super
end

def put_control()
    party_id = @json[0].to_i
    new_possession_monster_id = @json[1].to_i

    @parties[party_id].set(@user.id, new_possession_monster_id)
    @parties[party_id].save()

    @res.status = CREATED
    @context[:parties] = @parties
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

		@json.each { |x| Validator.validate_not_Naturalnumber(x) }

		raise "それお前のpartyじゃない" if @parties[@json[0.to_i]].nil?
	when "DELETE"
	end
end


end
