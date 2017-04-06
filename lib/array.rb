#!/usr/bin/ruby
# encoding: ASCII-8BIT

class Array

	def indices(value)
		# Returns an array containing index locations matching value
		counter = 0
		indices = []

		self.each do |v|
			indices << counter if value == v
			counter+=1
		end

		return indices

	end

	def sum()

		# Returns all values of the array summed
		# Assumes that all values are integers
		total = 0
		return total if self.length == 0
		self.each{|v| total += v}
		return total

	end

end