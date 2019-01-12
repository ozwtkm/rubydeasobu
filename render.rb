def render(template)

	file = File.open(template, "r")
	erb = ERB.new(file.read())
	return erb.result(binding)

end

