#!/usr/bin/ruby -Ku 
# -*- coding: utf-8 -*-
require_relative '../exception/Error_unset'

class Environment
    @@req = nil

    def self.set_req(req)
        @@req = req
    end
    
    def self.dev?()
        if @@req.nil?
            raise Error_unset.new("req")
        end

        if @@req.addr.last() === "127.0.0.1"
            return true
        else
            return false
        end
    end
end