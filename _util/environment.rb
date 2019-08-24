#!/usr/bin/ruby -Ku 
# -*- coding: utf-8 -*-
require_relative '../exception/Error_unset'

class Environment
    @@dev = nil

    DEVELOP = "dev"
    PRODUCTION = "pro"

    def self.method_missing(variable_name)
        Environment.check_unset()

        begin
            value = Environment.class_variable_get("@@" + variable_name.to_s)
        rescue
            raise variable_name.to_s + "なんて環境値は知らん"
        end

        return value
    end

    def self.check_unset()
        if @@dev.nil?
            raise Error_unset.new("dev")
        end
    end

    def self.dev?()
        Environment.check_unset()

        return @@dev
    end

    def self.set(dev_or_pro)
        const = Const.constants

        if dev_or_pro === DEVELOP
            @@dev = true

            const.each do |row|
                if row.to_s.match(/\ADEV_[A-Z_]+\z/).nil? === false
                    variable_name = row.to_s.downcase.sub(/\Adev_/, "")
                    variable_value = Const.const_get(row)

                    Environment.class_variable_set("@@"+variable_name, variable_value)
                end
            end
        elsif dev_or_pro === PRODUCTION
            @@dev = false

            const.each do |row|
                if row.to_s.match(/\ADEV_[A-Z_]+\z/).nil? === true
                    variable_name = row.to_s.downcase
                    variable_value = Const.const_get(row)

                    Environment.class_variable_set("@@"+variable_name, variable_value)
                end
            end
        else
            raise "環境を指定して起動しろ"
        end
    end

end