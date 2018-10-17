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
	
	print "<a href =matome.html>もどる</a><br><br>"
	print "</body>"
	
end

# オーバーライドする前提
def view_form()

	print ""

end


# オーバーライドする前提
def view_body()

	view_form()

end


def view()

	view_header()
	view_body()
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