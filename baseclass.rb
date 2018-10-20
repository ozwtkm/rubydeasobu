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


def validate_special_character(input_hash)

falselist = []
input_hash.each do |key, value| 

	if value.match(/\A[a-zA-Z0-9_@]+\z/) == nil then
		
		falselist << key 
		
	end
		
end

	if falselist != [] then
			
		falselist.each do |row|
			
			print "#{row}は/\A[a-zA-Z0-9_@]+\z/でよろ<br>"
			
		end
			
		exit!
			
	end
	
end


end