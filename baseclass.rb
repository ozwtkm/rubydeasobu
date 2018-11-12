


class Base

METHOD_GET = 0
METHOD_POST = 1
RESULT_SPECIAL_CHARACTER_ERROR = 0

def initialize()
	@view_buffer = ""
end


def view_header()

	@view_buffer += <<-EOS
Content-Type: text/html; charset=UTF-8\n
	EOS

end


def view_footer()
	
	@view_buffer += <<-EOS
<a href =matome.html>もどる</a><br><br>
</body>
	EOS
	
end

# オーバーライドする前提
def view_form()

	@view_buffer += ""

end


# オーバーライドする前提
def view_body(status={})

	@view_buffer += <<-EOS
\r\n\r\n<html>
<head>
<meta http-equiv="Content-type" content="text/html; charset=UTF-8">
</head>
<body>
	EOS

	view_form()
	# オーバーライドでここにstatusによるview分岐を書く

end


def view(status={})

	view_header()
	view_body(status)
	view_footer()
	
	print @view_buffer
	
end


def validate_special_character(input_hash)

falselist = []
input_hash.each do |key, value| 

	if value.match(/\A[a-zA-Z0-9_@]+\z/) == nil then
		
		falselist << key
		
	end
		
end	

if falselist != [] then
	
	raise Special_character_error.new(falselist)
			
end
	
return true
	
end


end



class Special_character_error < StandardError

attr_reader :falselist

def initialize(list)
	@falselist = list
end

end




