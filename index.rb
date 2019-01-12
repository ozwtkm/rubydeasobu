require 'erb'
require_relative './baseclass'
require_relative './render'

class Index < Base


def get_handler()

	view()
	
end


def post_handler()

	view()
	
end


# オーバーライド。
def view_http_body(status={})

	@res.body += render("index.erb")

end


end