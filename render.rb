

class Base

def self.render(template, context={})

	c = context
	erb = ERB.new(File.read(template))
	return erb.result(binding)

end

end


