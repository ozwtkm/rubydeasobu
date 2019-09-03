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
end

# オーバーライド
def view_http_header()
	@res.header['Content-Type'] = "application/json; charset=UTF-8"
end

def get_handler()
    @context[:parties] = @parties

	super
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
    @json = JSON.parse(@req.body)

    @json.each do |row|
        Validator.validate_not_Naturalnumber(row.to_s)
    end

    party_id = @json[0].to_i
    new_possession_monster_id = @json[1].to_i

    @parties[party_id].set(new_possession_monster_id)
    @parties[party_id].save()

    @res.status = CREATED
    @context[:parties] = @parties
end




end
