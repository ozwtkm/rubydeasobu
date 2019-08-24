#!/usr/bin/ruby -Ku 
# -*- coding: utf-8 -*-
require_relative '../exception/Error_unset'

class Environment
    @@dev = nil

    @@rootpath = nil
    @@path_view = nil
    @@path_controller = nil
    @@path_log = nil

    @@sql_socket = nil
    @@sql_host = nil
    @@sql_user = nil
    @@sql_password = nil
    
    @@cache_address = nil
    @@cache_port = nil

    @@documentdb_address = nil
    @@documentdb_port = nil

    @@webrick_address = nil
    @@webrick_port = nil

    @@websocket_address = nil
    @@websocket_port = nil

    DEVELOP = "dev"
    PRODUCTION = "pro"

    def self.dev?()
        Environment.check_unset()
        return @@dev
    end

    def self.rootpath()
        Environment.check_unset()
        return @@rootpath
    end

    def self.path_view()
        Environment.check_unset()
        return @@path_view
    end

    def self.path_controller()
        Environment.check_unset()
        return @@path_controller
    end

    def self.path_log()
        Environment.check_unset()
        return @@path_log
    end

    def self.sql_socket()
        Environment.check_unset()
        return @@path_log
    end

    def self.sql_host()
        Environment.check_unset()
        return @@sql_host
    end

    def self.sql_user()
        Environment.check_unset()
        return @@sql_user
    end

    def self.sql_password()
        Environment.check_unset()
        return @@sql_password
    end

    def self.cache_address()
        Environment.check_unset()
        return @@cache_address
    end

    def self.cache_port()
        Environment.check_unset()
        return @@cache_port
    end

    def self.documentdb_address()
        Environment.check_unset()
        return @@documentdb_address
    end

    def self.documentdb_port()
        Environment.check_unset()
        return @@documentdb_port
    end

    def self.webrick_address()
        Environment.check_unset()
        return @@webrick_address
    end

    def self.webrick_port()
        Environment.check_unset()
        return @@webrick_port
    end

    def self.websocket_address()
        Environment.check_unset()
        return @@websocket_address
    end

    def self.websocket_port()
        Environment.check_unset()
        return @@websocket_port
    end

    def self.check_unset()
        if @@dev.nil?
            raise Error_unset.new("dev")
        end
    end

    def self.set(dev_or_pro)
        if dev_or_pro === DEVELOP
            @@dev = true

            @@rootpath = DEV_ROOTPATH
            @@path_view = DEV_ROOTPATH + "template/"
            @@path_controller = DEV_ROOTPATH + "controller/"
            @@path_log = DEV_PATH_LOG
        
            @@sql_socket = DEV_SQL_SOCKET
            @@sql_host = DEV_SQL_HOST
            @@sql_user = DEV_SQL_USER
            @@sql_password = DEV_SQL_PASSWORD
            
            @@cache_address = DEV_CACHE_ADDRESS
            @@cache_port = DEV_CACHE_PORT
        
            @@documentdb_address = DEV_DOCUMENTDB_ADDRESS
            @@documentdb_port = DEV_DOCUMENTDB_PORT

            @@webrick_address = DEV_WEBRICK_ADDRESS
            @@webrick_port = DEV_WEBRICK_PORT
        
            @@websocket_address = DEV_WEBSOCKET_ADDRESS
            @@websocket_port = DEV_WEBSOCKET_PORT
        elsif dev_or_pro === PRODUCTION
            @@dev = false
            
            @@rootpath = ROOTPATH
            @@path_view = ROOTPATH + "template/"
            @@path_controller = ROOTPATH + "controller/"
            @@path_log = PATH_LOG
        
            @@sql_socket = SQL_SOCKET
            @@sql_host = SQL_HOST
            @@sql_user = SQL_USER
            @@sql_password = SQL_PASSWORD
            
            @@cache_address = CACHE_ADDRESS
            @@cache_port = CACHE_PORT

            @@documentdb_address = DOCUMENTDB_ADDRESS
            @@documentdb_port = DOCUMENTDB_PORT
        
            @@webrick_address = WEBRICK_ADDRESS
            @@webrick_port = WEBRICK_PORT
        
            @@websocket_address = WEBSOCKET_ADDRESS
            @@websocket_port = WEBSOCKET_PORT
        else
            raise "環境を指定して起動しろ"
        end
    end
end