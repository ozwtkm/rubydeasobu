#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'cgi'
require 'cgi/session'
require 'json'
require_relative './baseclass'
require_relative '../model/user'
require_relative '../model/monster'
require_relative '../model/wallet'

# クラス名、Walletとしたいが、そうするとmodelと衝突してまう
class Wallet_controller < Base

# オーバーライド。
def initialize(req,res)

	@template = "json.erb"

	super
	
	@context[:json] = "{}"
	
	ARGV.replace(["abc=001&def=002"]) # オフラインモード回避。
	@cgi = CGI.new
	
end


# オーバーライド
def view_http_header()

	@res.header['Content-Type'] = "application/json; charset=UTF-8"

end


def get_handler()

	begin

		set_session()
		
	rescue
	
		super
		
		return
	
	end
	
	@user = User.get_user(@session["name"], @sql_transaction)
	@wallet = Wallet.get_wallet(@user.id, @sql_transaction)
	
	gem = @wallet.gem
	money = @wallet.money
	
	@context[:json] = JSON.generate({:gem => gem, :money => money})
	
	super

end


# todo
def post_handler()

	super

end

# todo
def delete_handler()

	super

end


# todo
def put_handler()

	super

end


def control()

	

end


def set_session()

	# ToDo: cgiまわりの処理、baseclassかutilあたりに一般化したい

		@cgi.cookies['_session_id'] = get_sessionid(@req.header["cookie"].to_s)
		@session = CGI::Session.new(@cgi,{'new_session' => false})

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
