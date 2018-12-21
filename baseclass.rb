require 'webrick'


class Base < WEBrick::HTTPServlet::AbstractServlet

METHOD_GET = 0
METHOD_POST = 1
RESULT_SPECIAL_CHARACTER_ERROR = 0

def initialize(req,res)

	@req = req
	@res = res

end


def view_header()

	@res.header['Content-Type'] = "text/html; charset=UTF-8"

end


def view_footer()
	
	@res.body += <<-EOS
<a href =matome.html>もどる</a><br><br>
</body>
	EOS
	
end

# オーバーライドする前提
def view_form()

	@res.body += ""

end


# オーバーライドする前提
def view_body(status={})

	@res.body += <<-EOS
<html>
<head>
<meta http-equiv="Content-type" content="text/html; charset=UTF-8">
</head>
<body>
	EOS

	view_form()

end
	
def view(status={})

	view_header()
	view_body(status)
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
	
		raise Special_character_error.new(falselist)
			
	end
	
	return true
	
end


def add_new_line(message)

	return message + "<br>\r\n"

end

# オーバーライドするぜんてい
def get_handler()
	
end

# オーバーライドするぜんてい
def post_handler()

end


def not_allow_handler()

	@res.status = 405
	@res.body = "そのmethodだめ"

end

end


class Special_character_error < StandardError
attr_reader :falselist

def initialize(list)

	@falselist = list

end
end




