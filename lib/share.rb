# class to represent a network share
class Share

	attr_accessor :name, :type, :description, :host, :port

	def initialize(name=nil, type=nil, description=nil, host=nil, port=nil)
		@name = name
		@type = get_type(type)
		@description = description
		@host = host
		@port = port
	end

	def type=(id)
		# id is intended to be an integer in the range of 0..5
		@type = get_type(type)
	end

	def get_type(type)

		case type
		when 0
			return :DISK
		when 1
			return :PRINTER
		when 2
			return :DEVICE
		when 3
			return :IPC
		when 4
			return :SPECIAL
		when 5
			return :TEMPORARY
		else
			puts "Warning: Invalid type identifier provided! #{@type}"
			return nil
		end

	end

end