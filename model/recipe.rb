#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require_relative '../_util/SQL_master'
require_relative '../_util/SQL_transaction'
require_relative '../_util/cache'
require_relative './basemodel'


class Recipe < Base_model
	attr_reader :recipe_id, :recipe_name, :material_id, :required_number, :obtain_id

def initialize(recipe_info)
	@recipe_id = recipe_info["id"]
	@recipe_name = recipe_info["name"]
	@material_id = recipe_info["material_id"]
	@required_number = recipe_info["required_number"]
	@obtain_id = recipe_info["obtain_id"]
end

def self.get_recipes
	recipes = Cache.instance.get("recipes")
	
	if !recipes.nil?
		Log.log("cacheありなのでキャッシュからrecipesを取得した")
		return recipes
	end

	sql_master = SQL_master.instance.sql
	
	statement = sql_master.prepare("select * from master.gradeup_recipes")
	result = statement.execute
	
	Validator.validate_SQL_error(result.count, is_multi_line: true)

	recipes = {}
	result.each do |row|
		recipes[row["id"]] = Recipe.new(row)
	end

	statement.close

	Cache.instance.set("recipes", recipes)
	Log.log("cacheなしなのでrecipesをセットした")
	
	return recipes
end


def self.get_recipe(recipe_id)
	sql_master = SQL_master.instance.sql
	
	statement = sql_master.prepare("select * from master.gradeup_recipes where id = ? limit 1")
	result = statement.execute(recipe_id)
	
	Validator.validate_SQL_error(result.count)

	recipe = Recipe.new(result.first)

	statement.close
	
	return recipe
end


end

