#!/usr/bin/ruby

class Hash

	def stringify_keys()

		stringified = {}
		self.each {|k,v| stringified[k.to_s] = v}
		return stringified

	end

	def stringify_keys!()

		stringified = self.stringify_keys()
		self.clear
		stringified.each {|k,v| self[k] = v}

	end

end