# moduleはクラス変数に相当する機能はないらしいので、
# moduleはあきらめてクラスを作る。

require_relative './login'
#require_relative './regist'

class Routes

ROUTES = {
	"/regist" => "regist.rb",
	"/login" => Login
}

end