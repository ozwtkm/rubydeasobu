# moduleはクラス変数に相当する機能はないらしいので、
# moduleはあきらめてクラスを作る。

require_relative './login'
require_relative './regist'
require_relative './index'

class Routes

ROUTES = {
	"/regist" => Regist,
	"/login" => Login,
	"/index" => Index
}

end