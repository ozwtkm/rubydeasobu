#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'cgi'
require 'cgi/session'
require 'securerandom'
require 'json'
require_relative './baseclass_require_login'
require_relative '../model/user'
require_relative '../model/monster'
require_relative '../model/wallet'
require_relative '../model/gacha'


class Gacha_controller < Base_require_login

# オーバーライド。
def initialize(req, res)

	@template = "gacha.erb"

	super
	
end


def control()

	@wallet = Wallet.get_wallet(@user.id)
	
	begin
	
		check_gem(@wallet.gem)
	
	rescue
	
		@context[:msg] << "gem足りねえよ貧乏人が"
		
		return
	
	end
	
	
	@gacha = Gacha.get_gacha(@req.query["gacha_id"])
	
	begin
	
		obtain_monster_id = @gacha.execute_gacha()
	
	rescue
	
		@context[:msg] << "ごめんうまくいかなかった"
		
		return
	
	end


	Monster.add_monster(@user.id, obtain_monster_id)
	
	obtain_monster = Monster.get_master_monsters.select! { |key, value| key === obtain_monster_id }
	
	@context[:msg] << obtain_monster.values[0].name + "をGETしたよ"

	@wallet.sub_gem(100)
	@wallet.save()

end


def check_gem(gem)

	if gem < 100 then
	
		raise
	
	end

end


end
