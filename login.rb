#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'cgi'
require 'mysql2'
require 'digest/sha1'
require 'securerandom'
require 'cgi/session'

input = CGI.new
session = CGI::Session.new(input)
print input.header({"charset" => "UTF-8",})

sql = Mysql2::Client.new(:socket => '/var/lib/mysql/mysql.sock', :host => 'localhost', :username => 'testwebrick', :password => 'test', :encoding => 'utf8', :database => 'webrick_test')

print "<a href =matome.html>���ǂ�</a><br><br>"

# �ӂ��[�ށB
print <<EOM
<html>
<head>
        <meta http-equiv="Content-type" content="text/html; charset=UTF-8">
</head>
<body>
<h1>���O�C�����邼��</h1>
<form action="" method="post">
	���[�UID<br>
	<input type="text" name="name" value=""><br>
	�p�X���[�h(text�����Ȃ̂͒��ڂ��C)<br>
	<input type="text" name="passwd" value=""><br>
	<input type="submit" value="���O�C��"><br>
</form>
</body>
</html>
EOM

if input.request_method == "POST" then

	username = input["name"]
	passwd = input["passwd"]

	# ���O�C���\���`�F�b�N
	
	statement = statement = sql.prepare("select salt from users2 where name = ?")
	salt_tmp = statement.execute(username)
	salt_tmp.each do |row|
		row.each do |key,value|
			$salt = value
		end
	end
	
	pw_hash = Digest::SHA1.hexdigest(passwd+$salt)
	p pw_hash
	
	statement = sql.prepare("select COUNT(*) from users2 where name = ? and passwd = ?")
	exist_count_tmp = statement.execute(username, pw_hash)
	exist_count_tmp.each do |row|
		row.each do |key,value|
			$exist_count = value
		end
	end

	# 2�ȏ�ɂȂ邱�Ƃ͂Ȃ��S�ۂ�DB���̃J�����݌v��
	if $exist_count != 1 then 
	
		print "�o�����ė�����ȁi��FID�܂��̓p�X���[�h���������܂�"
	
	else

		print "���O�C��������<br><br>"
		
		## �����Z�b�V�����h�c�X�V������������Ȃ�
		session = CGI::Session.new(input,{"new_session"=>true})
		session['name'] = username
		## stored XSS
		print "�悤����" + session['name'] + "����"
	
	end
	
else

	print "<br><br>GET����"
	
end


