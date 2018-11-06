class Base

METHOD_GET = 0
METHOD_POST = 1
RESULT_SPECIAL_CHARACTER_ERROR = 0

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
def view_body(status={})

	view_form()
	# オーバーライドでここにstatusによるview分岐を書く

end


def view(status={})

	view_header()
	view_body(status)
	view_footer()

end


def validate_special_character(input_hash)

special_character_error = Special_character_error.new

input_hash.each do |key, value| 

	if value.match(/\A[a-zA-Z0-9_@]+\z/) == nil then
		
		special_character_error.falselist << key 
		
	end
		
end	

	if special_character_error.falselist != [] then
	
		raise special_character_error, special_character_error.falselist
			
	end
	
end

end



class Special_character_error < StandardError

attr_accessor :falselist
@falselist = []

end




