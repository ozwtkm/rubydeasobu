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


# オーバーライド
def view_http_header()

	@res.header['Content-Type'] = "application/json; charset=UTF-8"

end


def get_handler()

	@context[:wallet] = Wallet.get_wallet(@user.id)

	super

end


# todo
def post_handler()

	super

end

# todo
def delete_handler()

	super

end


# todo
def put_handler()

	super

end


def control()

	

end


end
