#!/usr/bin/ruby -Ku 
# -*- coding: utf-8 -*-

require_relative './controller/login'
require_relative './regist'
require_relative './index'
require_relative './chat'


# ここそのうち自動生成させたい
class Routes

ROUTES = {
	"/regist" => Regist,
	"/login" => Login,
	"/index" => Index,
	"/websocket" => Chat # 自動生成時ここ注意
}

end

