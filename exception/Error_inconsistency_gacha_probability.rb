#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require_relative './baseclass_exception'

class Error_inconsistency_gacha_probability < Base_exception

def initialize()

	super(500, "ごめんガチャがちょっとおかしいんで今は実行しないでクレメンス")

end

end