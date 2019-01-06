require_relative './baseclass'

class Index < Base


def get_handler()

	view()
	
end


def post_handler()

	view()
	
end


def view_html_body(status={})

	@res.body += <<-EOS
<h2>Rubyeeeee! TOP</h2>
<a href ="regist">ユーザ登録</a><br><br>
<a href ="login">ログイン</a><br><br>
	EOS

end




end