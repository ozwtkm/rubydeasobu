# インスタンスメソッドへのアクセスのてすと

class Classtest
 #attr_accessor :aaa
 
 def initialize ini
 @aaa = ini
 end

 
end

eee = Classtest.new("hhhh")

# aaaにアクセッサがあればえらーにならない
p eee.aaa