#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require "cgi"

print "Content-type: text/hTml; charset=UTF-8\n\n"
input = CGI.new
namae = input["name"]
print "<html><body>"
print "お名前 = #{namae}"
print "</body></html>"
