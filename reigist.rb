#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'cgi'
require 'mysql2'
require 'digest/sha1'
require 'securerandom'

print "Content-Type: text/html; charset=UTF-8\n\n"

sql = Mysql2::Client.new(:socket => '/var/lib/mysql/mysql.sock', :host => 'localhost', :username => 'testwebrick', :password => 'test', :encoding => 'utf8', :database => 'webrick_test')

print "<a href =matome.html>���ǂ�</a><br><br>"

# �ӂ��[�ށB
print <<EOM
<html>
<head>
        <meta http-equiv="Content-type" content="text/html; charset=UTF-8">
</head>
<body>
<h1>����o�^���邼��</h1>
<form action="" method="post">
	���[�UID<br>
	<input type="text" name="name" value=""><br>
	�p�X���[�h(text�����Ȃ̂͒��ڂ��C)<br>
	<input type="text" name="passwd" value=""><br>
	<input type="submit" value="�o�^���邼��"><br>
</form>
</body>
</html>
EOM

input = CGI.new

if input.request_method == "POST" then

	# POST���ꂽ�l��insert����B
	username = input["name"]
	passwd = input["passwd"]

	# ���[�UID���d���`�F�b�N
	statement = sql.prepare("select COUNT(*) from users2 where name = ?")
	exist_count = statement.execute(username)
	
	p exist_count
	
	if exist_count != 0 then
	
		print "�L������肗"
		
		
	else 
	
	# salt�𐶐�
	salt = SecureRandom.hex(10) + "aaaaburiburi"
	
	# salt�ƃp�X���[�h��A�����ăn�b�V���l����
	pw_hash = Digest::SHA1.hexdigest(passwd+salt)
	
	# �Ԃ�����
	statement = sql.prepare("insert into users2(name,salt,passwd) values(?,?,?)")
	statement.execute(username, salt, pw_hash)

	print "<h2>���[�U�ꗗ</h2>"
	
	res = sql.query("select * from users2")
		p row
	end

else

	p "GET����"
	
end

