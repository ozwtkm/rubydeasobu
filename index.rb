require_relative './baseclass'

class Index < Base


# オーバーライド。
def view_http_body()

	@res.body += render("index.erb")

end


end