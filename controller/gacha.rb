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
	
	@user = User.new(@sql)
	
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

	@user = User.new(@sql)
	
	begin
	
		set_session()
		@user_id = @user.get_userid(@session["name"])
	
	rescue
	
		@context[:msg] << "ログインしろゴミが"
	
		super
		
		return
	
	end

	super

end


def control()

	@wallet = Wallet.get_wallet(@sql)
	@monster = Monster.new(@sql)
	@gacha = Gacha.new(@sql)
	
	gem = @wallet.get_gem(@user_id)
	
	begin
	
		check_gem(gem)
	
	rescue
	
		@context[:msg] << "gem足りねえよ貧乏人が"
		
		return
	
	end
	

	begin
	
		execute_gacaha()
	
	rescue
	
		@context[:msg] << "ごめんうまくいかなかった"
		
		return
	
	end


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

# To do 個々の処理を関数化
def execute_gacaha()

	probability = @gacha.get_probability(@req.query["gacha_id"])
	
	probability_range_tmp = []
	
	probability.each do |row|
	
		id = row["monster_id"]
		pro = row["probability"]
	
		probability_range_tmp << {id => pro}
	
	end
	
	
	probability_range = []
	for i in 0 .. probability_range_tmp.length-1 do

		if i == 0 then
		
			probability_range[i] = {probability_range_tmp[i].keys[0] => probability_range_tmp[i].values[0]}
		
		else
		
			probability_range[i] = {probability_range_tmp[i].keys[0] => probability_range_tmp[i].values[0] + probability_range[i-1].values[0]}
			
		end

		i+=1
	
	end


	if probability_range.last.values[0] != 100000
	
		raise
	
	end


	random = SecureRandom.random_number(99999)

	obtain_monster_id = 0
	for i in 0 .. probability_range.length-1 do
	
		if random < probability_range[i].values[0] then
		
			obtain_monster_id = probability_range[i].keys[0]
			
			break
			
		end
	
		i+=1
	
	end

	@monster.add_monster(@user_id, obtain_monster_id)
	
	obtain_monster_name = @monster.get_monster_name(obtain_monster_id)

	@context[:msg] << obtain_monster_name + "をGETしたよ"

	@wallet.sub_gem(@user_id, 100)

end


end
