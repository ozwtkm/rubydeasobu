#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require_relative './_baseclass_require_login'
require_relative '../model/monster'
require_relative '../model/recipe'
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
	recipe_id = @json[0]

	@recipe = Recipe.get_recipe(recipe_id)
	@recipe.run(@user.id)
	
	@context[:monster] = Monster.get_specific_monster(@recipe.obtain_id)
end

def validate_post_input()
	raise "JSON形式(1要素の配列)でよろ" if @json.class != Array || @json.count != 1

	@json.each {|x| Validator.validate_not_Naturalnumber(x)}
end


end
