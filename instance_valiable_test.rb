
abc = nil # �����Ő錾���Ƃ��Ȃ��ƃG���[

class Test

attr_accessor :def

def aiueo(input)

	abc = input
	p abc # AAAAA
	@def = input

end	

end

test = Test.new

test.aiueo("AAAAAA")
p abc # nil
p test.def # AAAAAA
