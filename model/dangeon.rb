#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
require_relative '../_util/SQL_master'
require_relative '../_util/SQL_transaction'
require_relative '../_util/cache'
require_relative './basemodel'

class Dangeon < Base_model
    attr_reader :id, :name

def initialize(dangeon_info)
    @id = dangeon_info["id"]
    @name = dangeon_info["name"]
end

def self.get_list()
    dangeon_list = Cache.instance.get('dangeon_list')

    if !dangeon_list.nil?
		Log.log("cacheありなのでキャッシュからdangeon_list取得した")	
		return dangeon_list
	end

    sql_master = SQL_master.instance.sql

    # todo memcached
    statement = sql_master.prepare("select * from dangeons")
	result = statement.execute()

	Validator.validate_SQL_error(result.count, is_multi_line: true)
	
	dangeon_list = {}
	result.each do |row|
		dangeon_list[row["id"]] = Dangeon.new(row)
	end

    statement.close
    
    Cache.instance.set('dangeon_list',dangeon_list)

	Log.log("cacheなしなのでセットした")

    return dangeon_list
end

end