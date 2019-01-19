require_relative './baseclass'

class Index < Base

def initialize(req,res)

	super
	
	@template = "index.erb"

end



end