class A

def a_method()

	p "a"

end

end



class B

def b_method(a_instance)

	a_instance.a_method()

end


end

a_instance = A.new
b_instance = B.new


# a���o�͂����
b_instance.b_method(a_instance)





