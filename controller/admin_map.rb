#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
require_relative './_baseclass_require_admin'

class Admin_map_controller < Base_require_admin

# あくまでmap生成のUIを生成するだけのページ。動的処理はmap_editに分離した。
def initialize(req, res)
	@template = "admin_map.erb"
	super
end

end


