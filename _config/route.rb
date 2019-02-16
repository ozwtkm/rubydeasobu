#!/usr/bin/ruby -Ku 
# -*- coding: utf-8 -*-

require_relative './controller/login'
require_relative './controller/regist'
require_relative './controller/index'
require_relative './controller/chat'


# ここそのうち自動生成させたい
class Routes

ROUTES = {
	"/regist" => Regist,
	"/login" => Login,
	"/index" => Index,
	"/websocket" => Chat # 自動生成時ここ注意
}

end

