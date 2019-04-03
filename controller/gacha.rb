#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'cgi'
require 'cgi/session'
require 'securerandom'
require 'json'
require_relative './baseclass'
require_relative '../model/user'
require_relative '../model/monster'
require_relative '../model/wallet'
require_relative '../model/gacha'

class Gacha_controller < Base

# オーバーライド。
def initialize(req,res)

	@template = "gacha.erb"

	super
	
	@context[:msg] = []
		
	ARGV.replace(["abc=001&def=002"]) # オフラインモード回避。
	@cgi = CGI.new
	
end


def get_handler()
	
	begin
	
		set_session()
	
	rescue
	
		@context[:msg] << "ログインしろゴミが"
	
		super
		
		return
	
	end

	super

end



# todo
def post_handler()
	
	begin
	
		set_session()
		@user = User.get_user(@session["name"], @sql)

	rescue
	
		@context[:msg] << "ログインしろゴミが"
	
		view()
		
		return
	
	end

	super

end


def control()

	@wallet = Wallet.get_wallet(@user.id, @sql)
	@master_monster = Monster.get_master_monsters(@sql)
	@gacha = Gacha.get_gacha(@req.query["gacha_id"], @sql)
	
	begin
	
		check_gem(@wallet.gem)
	
	rescue
	
		@context[:msg] << "gem足りねえよ貧乏人が"
		
		return
	
	end
	

	begin
	
		obtain_monster_id = @gacha.execute_gacha()
	
	rescue
	
		@context[:msg] << "ごめんうまくいかなかった"
		
		return
	
	end

	Monster.add_monster(@sql, @user.id, obtain_monster_id)
	
	obtain_monster = @master_monster.select { |row| row.id === obtain_monster_id }
	obtain_monster_name = obtain_monster[0].name

	@context[:msg] << obtain_monster_name + "をGETしたよ"

	@wallet.sub_gem(100)
	@wallet.save(@sql)

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


def check_gem(gem)

	if gem < 100 then
	
		raise
	
	end

end


end
