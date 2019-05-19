#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'cgi'
require_relative './_baseclass_require_login'
require_relative '../model/user'
require_relative '../model/monster'
require_relative '../model/recipe'
require_relative '../exception/Error_shortage_of_gem'

class Gradeup_controller < Base_require_login

# オーバーライド。
def initialize(req, res)
	@template = "gradeup.erb"

	super
end


# オーバーライド
def get_handler()
	recipes = Recipe.get_recipes
	@context[:recipes] = recipes
	
	super
end


def control()
	@recipe = Recipe.get_recipe(@req.query["recipe_id"].to_i)
	
	run_gradeup
	
	@context[:recipe] = @recipe
end


# 合成の仕様が今後複雑化すると行数増えるからcontrol()から分離した。
def run_gradeup
	Monster.delete_monster(@user.id, @recipe.material_id, @recipe.required_number) # required_numberを満たすかはmodel側で検証
	Monster.add_monster(@user.id, @recipe.obtain_id)
end


end
