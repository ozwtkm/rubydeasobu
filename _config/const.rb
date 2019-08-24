#!/usr/bin/ruby -Ku 
# -*- coding: utf-8 -*-

class Const
    ROOTPATH = "/var/www/html/testruby/"
    PATH_VIEW = "/var/www/html/testruby/template/"
    PATH_CONTROLLER = "/var/www/html/testruby/controller/"

    DEV_ROOTPATH = "/var/www/html/dev/rubyquest/"
    DEV_PATH_VIEW = "/var/www/html/dev/rubyquest/template/"
    DEV_PATH_CONTROLLER = "/var/www/html/dev/rubyquest/controller/"

    SQL_SOCKET = "/var/lib/mysql/mysql.sock"
    SQL_HOST = "localhost"
    SQL_USER = "testwebrick"
    SQL_PASSWORD = "test"

    DEV_SQL_SOCKET = "/var/lib/mysql/mysql.sock"
    DEV_SQL_HOST = "localhost"
    DEV_SQL_USER = "testwebrick"
    DEV_SQL_PASSWORD = "test"


    CACHE_ADDRESS = "127.0.0.1"
    CACHE_PORT = "11211"

    DEV_CACHE_ADDRESS = "127.0.0.1"
    DEV_CACHE_PORT = "11212"


    DOCUMENTDB_ADDRESS = "127.0.0.1"
    DOCUMENTDB_PORT = "27017"

    DEV_DOCUMENTDB_ADDRESS = "127.0.0.1"
    DEV_DOCUMENTDB_PORT = "27018"


    PATH_LOG = "/var/log/rubydeasobu/"

    DEV_PATH_LOG = "/var/log/dev_rubydeasobu/"


    WEBRICK_ADDRESS = "127.0.0.1"
    WEBRICK_PORT = "8082"

    DEV_WEBRICK_ADDRESS = "127.0.0.1"
    DEV_WEBRICK_PORT = "9998"


    WEBSOCKET_ADDRESS = "127.0.0.1"
    WEBSOCKET_PORT = "8882"

    DEV_WEBSOCKET_ADDRESS = "127.0.0.1"
    DEV_WEBSOCKET_PORT = "9999"
end