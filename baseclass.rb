class Base

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
	
	print "<a href =matome.html>���ǂ�</a><br><br>"
	print "</body>"
	
end


def view_form()

	print <<EOM
<h1>����o�^���邼��</h1>
<form action="" method="post">
���[�UID<br>
<input type="text" name="name" value=""><br>
�p�X���[�h(text�����Ȃ̂͒��ڂ��C)<br>
<input type="text" name="passwd" value=""><br>
<input type="submit" value="�o�^���邼��"><br>
</form>

EOM

end


def view_body(view_buffer)

	print view_buffer

end


def validate_special_character(input)

		if input.match(/\A[a-zA-Z0-9_@]+\z/) == nil
	
			return false
		
		else
	
			return true
	
		end
	
end


end