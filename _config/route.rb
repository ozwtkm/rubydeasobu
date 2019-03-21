#!/usr/bin/ruby -Ku 
# -*- coding: utf-8 -*-

require_relative '../controller/login'
require_relative '../controller/regist'
require_relative '../controller/index'
require_relative '../controller/gacha'
require_relative '../controller/chat'
require_relative '../controller/monsters'
require_relative '../controller/wallet'


# ここそのうち自動生成させたい
class Routes

ROUTES = {
	"/regist" => Regist,
	"/login" => Login,
	"/index" => Index,
	"/gacha" => Gacha,
	"/monsters" => Monsters,
	"/wallet" => Wallet_controller,
	"/websocket" => Chat # 自動生成時ここ注意
}

end


