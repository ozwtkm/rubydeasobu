#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'cgi'
require 'cgi/session'
require 'securerandom'
require 'json'
require_relative './_baseclass_require_login'
require_relative '../model/user'
require_relative '../model/monster'
require_relative '../model/wallet'
require_relative '../model/gacha'
require_relative '../exception/Error_shortage_of_gem'

class Gacha_controller < Base_require_login
	GEM_REQUIRED_EXECUTE_GACHA = 100 # こういうの別ファイルに引っ越したい

def initialize(req, res)
	@template = "gacha.erb"

	super
end

# オーバーライド。
def get_control()
	gachas = Gacha.get_gachas()

	@context[:gachas] = gachas
end


def post_control()
	@json = JSON.parse(@req.body)
	check_input_json()
	gacha_id = @json[0]

	@wallet = Wallet.get_wallet(@user.id)

	validate_gem_amount()
	
	gacha = Gacha.get_probability(gacha_id)
	obtain_monster_id = gacha.execute_gacha()
	Monster.add_monster(@user.id, obtain_monster_id)

	@wallet.sub_gem(100)
	@wallet.save()

	@context[:monster] = Monster.get_master_monsters()[obtain_monster_id]
end

# モデルでも検証するべきだがここでも。
def validate_gem_amount()
	if @wallet.gem < 100 then
		raise Error_shortage_of_gem.new
	end
end

# utilに引っ越したい
def check_input_json()
	if !@json.all?{|x| (0..9).to_a.include?(x)}
		raise "0-9でよろ" 
	end
end


end
