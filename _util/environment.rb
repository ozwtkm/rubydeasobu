#!/usr/bin/ruby -Ku 
# -*- coding: utf-8 -*-
require_relative '../exception/Error_unset'

class Environment
    @@dev = nil

    DEVELOP = "dev"
    PRODUCTION = "pro"

    def self.method_missing(variable_name)
        begin
            value = Environment.class_variable_get("@@" + variable_name.to_s)
        rescue
            raise variable_name.to_s + "なんて環境値は知らん"
        end

        return value
    end

    def self.set(dev_or_pro)
        const = Const.constants

        if dev_or_pro === DEVELOP
            @@dev = true
        elsif dev_or_pro === PRODUCTION
            @@dev = false
        else
            raise "環境を指定して起動しろ"
        end

        Environment.set_variables(const)
        
        begin
            rootpath = Environment.rootpath()
            @@path_controller = rootpath + "controller/"
            @@path_view = rootpath + "template/"
        rescue
            raise "rootパスが定義できていない"
        end
    end

    def self.set_variables(const)
        prefix = "PRO_" 
        prefix = "DEV_" if Environment.dev()
        const = const.select do |row|
            row.to_s.start_with?(prefix)
        end

        regexp = Regexp.new(prefix)
        const.each do |row|
                variable_name = row.to_s.sub(regexp, "").downcase
                puts variable_name
                variable_value = Const.const_get(row)

                Environment.class_variable_set("@@"+variable_name, variable_value)
        end
    end

end