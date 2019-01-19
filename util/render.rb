

class Base

def render(template, context={})

	c = context
	erb = ERB.new(File.read(template))
	return erb.result(binding)

end

end


