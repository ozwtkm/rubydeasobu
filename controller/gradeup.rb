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
def get_control()
	recipes = Recipe.get_recipes()

	@context[:recipes] = recipes
end


def post_control()	
	@json = JSON.parse(@req.body)
	check_json()

	recipe_id = @json[0]

	@recipe = Recipe.get_recipe(recipe_id)
	
	run_gradeup()
	
	@context[:monster] = Monster.get_specific_monster(@recipe.obtain_id)
end


# これcontrollerの仕事か？
def run_gradeup()
	Monster.delete_monster(@user.id, @recipe.material_id, @recipe.required_number) # required_numberを満たすかはmodel側で検証
	Monster.add_monster(@user.id, @recipe.obtain_id)
end


def check_json()
	if !@json.all?{|x| (0..Float::INFINITY).include?(x)}
		raise "0か自然数でよろ" 
	end
end


end
