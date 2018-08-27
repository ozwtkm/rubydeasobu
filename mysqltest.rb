#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'cgi'
require 'mysql2'

print "Content-Type: text/html; charset=UTF-8\n\n"
print "Hello World<br><br>"

sql = Mysql2::Client.new(:socket => '/var/lib/mysql/mysql.sock', :host => 'localhost', :username => 'testwebrick', :password => 'test', :encoding => 'utf8', :database => 'webrick_test')

=begin
sql.query("select * from test").each do |row|
  p row
end
=end

# �ӂ��[�ށB
print <<EOM
<html>
<head>
        <meta http-equiv="Content-type" content="text/html; charset=euc-jp">
</head>
<body>
<h1>TEST SQL �ӂ��[��</h1>
	<form action="" method="post">
	INSERT INTO test(name) values(��);<br>
	<input type="text" name="name" value="">
	<input type="submit" value="���s">
</form>
</body>
</html>
EOM

input = CGI.new

if input.request_method == "POST" then

	# POST���ꂽ�l��insert����B

	insert_name = input["name"]

	statement = sql.prepare("insert into test(name) values(?)")
	statement.execute(insert_name)

	res = sql.query("select * from test")

	res.each do |row|
	    row.each do |key,value|
		puts "#{value}" + "<br>"
		end
	end
	
else

	p "GET����"
	
end