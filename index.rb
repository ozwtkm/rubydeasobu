require_relative './baseclass'

class Index < Base


# オーバーライド。
def view_http_body(status={})

	@res.body += Base.render("index.erb")

end


end