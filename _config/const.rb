#!/usr/bin/ruby -Ku 
# -*- coding: utf-8 -*-

class Const
    PRO_ROOTPATH = "/var/www/html/testruby/"

    DEV_ROOTPATH = "/var/www/html/dev/rubyquest/"

    PRO_SQL_SOCKET = "/var/lib/mysql/mysql.sock"
    PRO_SQL_HOST = "localhost"
    PRO_SQL_USER = "testwebrick"
    PRO_SQL_PASSWORD = "test"

    DEV_SQL_SOCKET = "/var/lib/mysql/mysql.sock"
    DEV_SQL_HOST = "localhost"
    DEV_SQL_USER = "testwebrick"
    DEV_SQL_PASSWORD = "test"


    PRO_CACHE_ADDRESS = "127.0.0.1"
    PRO_CACHE_PORT = "11211"

    DEV_CACHE_ADDRESS = "127.0.0.1"
    DEV_CACHE_PORT = "11212"


    PRO_DOCUMENTDB_ADDRESS = "127.0.0.1"
    PRO_DOCUMENTDB_PORT = "27017"

    DEV_DOCUMENTDB_ADDRESS = "127.0.0.1"
    DEV_DOCUMENTDB_PORT = "27018"


    PRO_PATH_LOG = "/var/log/rubydeasobu/"

    DEV_PATH_LOG = "/var/log/dev_rubydeasobu/"


    PRO_WEBRICK_ADDRESS = "127.0.0.1"
    PRO_WEBRICK_PORT = "8082"

    DEV_WEBRICK_ADDRESS = "127.0.0.1"
    DEV_WEBRICK_PORT = "9998"


    PRO_WEBSOCKET_ADDRESS = "127.0.0.1"
    PRO_WEBSOCKET_PORT = "8882"

    DEV_WEBSOCKET_ADDRESS = "127.0.0.1"
    DEV_WEBSOCKET_PORT = "9999"
end