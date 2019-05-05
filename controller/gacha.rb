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

# オーバーライド。
def initialize(req, res)

	@template = "gacha.erb"

	super
	
end


def control()

	@wallet = Wallet.get_wallet(@user.id)

	check_gem()
	
	@gacha = Gacha.get_gacha(@req.query["gacha_id"])

	obtain_monster_id = @gacha.execute_gacha()

	Monster.add_monster(@user.id, obtain_monster_id)

	@wallet.sub_gem(100)
	@wallet.save()
	@context[:monster] = Monster.get_master_monsters[obtain_monster_id]

end


def check_gem()

	if @wallet.gem < 100 then
	
		raise Error_shortage_of_gem.new
	
	end

end


end
