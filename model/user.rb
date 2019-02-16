#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

class User

def initialize(sql)

	@sql = sql

end


def regist(username, passwd)

	salt = SecureRandom.hex(10) + "aaaaburiburi"
		
	pw_hash = Digest::SHA1.hexdigest(passwd+salt)
		
	statement = @sql.prepare("insert into users2(name,salt,passwd) values(?,?,?)")
	statement.execute(username, salt, pw_hash)

end

end





