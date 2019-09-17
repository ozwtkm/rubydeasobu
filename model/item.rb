#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
require_relative '../_util/SQL_master'
require_relative '../_util/SQL_transaction'
require_relative '../_util/serializer'
require_relative '../_util/cache'
require_relative './basemodel'

class Item < Base_model
	attr_reader :id, :name, :kind, :value, :img_id

def initialize(item_info)
	@id = item_info["id"]
	@name = item_info["name"]
	@kind = item_info["kind"]
	@value = item_info["value"]
	@img_id = item_info["img_id"]
end


def self.get_master_items()
	master_item_list = Cache.instance.get('master_item_list')

	if !master_item_list.nil?
		Log.log("cacheありなのでitemキャッシュから取得した")	
		return master_item_list
	end
	
	sql_master = SQL_master.instance.sql

	statement = sql_master.prepare("select * from items")
	result = statement.execute()

	Validator.validate_SQL_error(result.count, is_multi_line: true)
	
	master_item_list = {}
	result.each do |row|
		master_item_list[row["id"]] = Item.new(row)
	end

	statement.close
	
	Cache.instance.set('master_item_list',master_item_list)

	Log.log("cacheなしなのでitemセットした")
	return master_item_list
end


def self.get_specific_item(id)
    item_list = Item.get_master_items()

    item = item_list[id]

    return item
end

# kakikake
def self.get_possession_items(user_id, limit:10, offset:0)
	sql_transaction =  SQL_transaction.instance.sql
	
    master_item_list = Item.get_master_monsters()
	

end


end

