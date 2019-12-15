#!/usr/bin/ruby -Ku 
# -*- coding: utf-8 -*-
require_relative './SQL_transaction'
require_relative './SQL_master'


# mysql2のclientの使い勝手をラクにするためのクラス
class SQL
    @@tmp_statement = []

    class << self

        def transaction(query, arg=nil)
            @@tmp_statement << SQL_transaction.instance.sql.prepare(query)

            if arg.nil?
                result = @@tmp_statement.last.execute()
            elsif arg.class == Array
                result = @@tmp_statement.last.execute(*arg)
            else
                result = @@tmp_statement.last.execute(arg)
            end

            if defined?(result.count)
                if result.count === 1
                    return result.first
                elsif result.count > 1
                    return result.map {|x| x}
                end
            end

            result
        end


        def master(query, arg=nil)
            @@tmp_statement << SQL_master.instance.sql.prepare(query)

            if arg.nil?
                result = @@tmp_statement.last.execute()
            elsif arg.class == Array
                result = @@tmp_statement.last.execute(*arg)
            else
                result = @@tmp_statement.last.execute(arg)
            end

            if defined?(result.count)
                if result.count === 1
                    return result.first
                elsif result.count > 1
                    return result.map {|x| x}
                end
            end

            result
        end


        def close_statement()
            return if @@tmp_statement === []

            @@tmp_statement.each do |row|
                row.close()
            end

            @@tmp_statement = []        
        end

    end

end