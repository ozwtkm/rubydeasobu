﻿class Base

def view_header()

	print <<EOM
Content-Type: text/html; charset=UTF-8\r\n\r\n
<html>
<head>
<meta http-equiv="Content-type" content="text/html; charset=UTF-8">
</head>
<body>
EOM
		
end


def view_footer()
	
	print "<a href =matome.html>もどる</a><br><br>"
	print "</body>"
	
end


def view_form(kind_form)

	case kind_form
	when "regist" then
	
		print <<EOM
<h1>会員登録するぞい</h1>
<form action="" method="post">
ユーザID<br>
<input type="text" name="name" value=""><br>
パスワード(text属性なのは茶目っ気)<br>
<input type="text" name="passwd" value=""><br>
<input type="submit" value="登録するぞい"><br>
</form>
EOM

	when "login" then

		print ""
		
	else
	
		print ""
	
	end

end


def view_body(view_buffer)

	print view_buffer

end


def view(view_buffer , kind_form = false)

	view_header()
	view_form(kind_form)
	view_body(view_buffer)
	view_footer()

end


def validate_special_character(input)

		if input.match(/\A[a-zA-Z0-9_@]+\z/) == nil
	
			return false
		
		else
	
			return true
	
		end
	
end


end