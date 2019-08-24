#!/usr/bin/ruby -Ku 
# -*- coding: utf-8 -*-

ROOTPATH = "/var/www/html/testruby/"

DEV_ROOTPATH = "/var/www/html/dev/rubyquest/"

PATH_VIEW = ROOTPATH + "template/"
PATH_CONTROLLER = ROOTPATH + "controller/"


SQL_SOCKET = "/var/lib/mysql/mysql.sock"
SQL_HOST = "localhost"
SQL_USER = "testwebrick"
SQL_PASSWORD = "test"


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