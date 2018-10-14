
kkk = nil 

class Test

attr_accessor :aaa


def initialize

	@aaa

end

def aiueo(input)

	input.each do |key|
	
		p kkk # undefined
		kkk = key
		p kkk # aaaaa
		
	end

	 p kkk # undefined
	
	
end

end


test = Test.new

test.aiueo(["aaaaaa"])
p kkk # nil