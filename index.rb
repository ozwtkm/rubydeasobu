require_relative './baseclass'
require 'erb'


class Index < Base


def get_handler()

	view()
	
end


def post_handler()

	view()
	
end


def view_html_body(status={})

	file = File.open("index.erb", "r")
  erb = ERB.new(file.read())

	@res.body += erb.result(binding)

end


end