#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
require 'cgi'
require 'cgi/session'


input = CGI.new
session = CGI::Session.new(input, {"new_session" => false})


print input.header({"charset" => "UTF-8",})


p ENV

if session['name'].nil?
 puts "ない"
else
 puts "aru"
end


print session['name']



