#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'cgi'
require 'cgi/session'
require 'digest/sha1'
require_relative './baseclass'
require_relative '../model/user'
require_relative '../model/monster'
require_relative '../model/wallet'
require 'json'

class Gacha < Base

# オーバーライド。
def initialize(req,res)

	@template = "gacha.erb"

	super
	
	@context[:msg] = []
	@context[:monsters] = []
	@context[:gem] = ""
	@context[:money] = ""
	
	ARGV.replace(["abc=001&def=002"]) # オフラインモード回避。
	@cgi = CGI.new
	
	@monster = Monster.new(@sql)
	
end


def get_handler()
	
	@user = User.new(@sql)
	
	begin
	
		set_session()
		user_id = @user.get_userid(@session["name"])
	
	rescue
	
		@context[:msg] << "ログインしろゴミが"
	
		super
		
		return
	
	end

	monsters = @monster.get_monsters(user_id)
	monsters.each do |row|
			
			@context[:monsters] << {:name => row['name'], :rarity => row['rarity']}
	
	end
	
	@wallet = Wallet.get_wallet(@sql)
	
	@context[:gem] = @wallet.get_gem(user_id).to_s
	@context[:money] = @wallet.get_money(user_id).to_s
	
	super

end


# todo
def post_handler()

	set_session()

	super

end


def control()

	

end


def set_session()

	# ToDo: cgiまわりの処理、baseclassかutilあたりに一般化

	@cgi.cookies['_session_id'] = get_sessionid(@req.header["cookie"].to_s)
	@session = CGI::Session.new(@cgi,{'new_session' => false})
	
	@context[:msg] << "ようこそ" + @session['name'] + "さん"

end


def get_sessionid(header)

	# ここの正規表現いけてない
	match = header.match(/session_id=([a-f0-9]+)/)
 
	 if match.nil? then
		
		raise
		
	 end
 
	return match[1]

end



end
