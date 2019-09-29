#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'cgi'
require 'cgi/session'
require 'json'
require_relative './_baseclass'
require_relative '../model/user'
require_relative '../model/monster'
require_relative '../model/wallet'
require_relative './_baseclass_require_login'

# クラス名、Walletとしたいが、そうするとmodelと衝突してまう
class Wallet_controller < Base_require_login

# オーバーライド。
def initialize(req,res)
	@template = "wallet.erb"

	super
end

def get_control()
	@context[:wallet] = Wallet.get_wallet(@user.id)
end


end
