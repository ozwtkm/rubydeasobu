class Base

def render(template, context={})

	# 単純に「context」だと長いから代入して変数名を短くしてるだけ。
	c = context
	erb = ERB.new(File.read("/var/www/html/testruby/template/" + template))
	return erb.result(binding)
	
end

end


