#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
require_relative '../_util/SQL_master'
require_relative '../_util/SQL_transaction'
require_relative '../_util/serializer'
require_relative '../_util/cache'
require_relative './basemodel'

class Equipment < Base_model
	attr_reader :id, :name, :kind, :value

def initialize(equipment_info)
	@id = equipment_info["id"]
	@name = equipment_info["name"]
	@kind = equipment_info["kind"]
	@value = equipment_info["value"]
end


def self.get_master_equipments()
	master_equipment_list = Cache.instance.get('master_equipment_list')

	if !master_equipment_list.nil?
		Log.log("cacheありなのでequipmentキャッシュから取得した")	
		return master_equipment_list
	end
	
	sql_master = SQL_master.instance.sql

	statement = sql_master.prepare("select * from equipment")
	result = statement.execute()

	Validator.validate_SQL_error(result.count, is_multi_line: true)
	
	master_equipment_list = {}
	result.each do |row|
		master_equipment_list[row["id"]] = Equipment.new(row)
	end

	statement.close
	
	Cache.instance.set('master_equipment_list',master_equipment_list)

	Log.log("cacheなしなのでequipmentセットした")
	return master_equipment_list
end


def self.get_specific_equipment(id)
    equipment_list = Equipment.get_master_equipments()

    equipment = equipment_list[id]

    return equipment
end



end