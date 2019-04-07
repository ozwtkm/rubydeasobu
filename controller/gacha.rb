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
def initialize(req,res)

	@template = "gacha.erb"

	super
	
end


def control()

	@user = User.get_user(@session["name"])
	@wallet = Wallet.get_wallet(@user.id)
	@master_monster = Monster.get_master_monsters()
	@gacha = Gacha.get_gacha(@req.query["gacha_id"])
	
	begin
	
		check_gem(@wallet.gem)
	
	rescue
	
		@context[:msg] << "gem足りねえよ貧乏人が"
		
		return
	
	end
	

	begin
	
		obtain_monster_id = @gacha.execute_gacha()
	
	rescue
	
		@context[:msg] << "ごめんうまくいかなかった"
		
		return
	
	end

	Monster.add_monster(@user.id, obtain_monster_id)
	
	obtain_monster = @master_monster.select { |row| row.id === obtain_monster_id }
	obtain_monster_name = obtain_monster[0].name

	@context[:msg] << obtain_monster_name + "をGETしたよ"

	@wallet.sub_gem(100)
	@wallet.save()

end


def check_gem(gem)

	if gem < 100 then
	
		raise
	
	end

end


end
