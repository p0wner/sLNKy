class Alerts

	attr_accessor :symbol, :wrapper, :indlevel, :message, :indchar

	def initialize(symbol='+', wrapper='[]', message='', indlevel=0, indchar="\t")
		@symbol = symbol
		@wrapper = wrapper
		@indlevel = indlevel
		@message = message
		@indchar = indchar
	end

	def reset!(var=nil)

		case var
		when :symbol
			@symbol = '+'

		when :wrapper
			@wrapper = '[]'

		when :message
			@message = ''

		when :indlevel
			@indlevel = 0

		when :indchar
			@indchar = "\t"

		else
			@symbol = '+'
			@wrapper = '[]'
			@message = ''
			@indlevel = 0
			@indchar = "\t"

		end

	end

	def alert(message=nil, newline=true, prefix=true)

		mback = @message
		@message = message if message

		alert = self.build(prefix)
		alert += "\n" if newline

		print alert

		@message = mback

	end

	def build(prefix=true)

		if prefix
			return ("\t" * @indlevel) +	wrap_symbol + " " +	@message
		else
			return ("\t" * @indlevel) + @message
		end

	end

	def wrap_symbol()

		return @wrapper.dup
			.split('')
			.insert(1, @symbol)
			.join('')

	end

	def wrapper=(w)

		if wrapper.length != 2
			raise "Wrapper must consist of two characters, e.g. '[]'"
		end

		@wrapper = w

	end

	# set indent level
	def indlevel=(i)

		raise if i < 0
		@indlevel=i
		rescue
			puts "Warning: Indent level must be greater than or equal to zero (i > 0)"
			puts "Resetting indent level to 0"
			@indlevel = 0

	end

	# shortcut to set indent level
	def ind=(i)
		raise if i < 0
		indlevel=(i)
	end

	# increase indent level
	def incind(i=1)
		raise if i < 0
		@indlevel += i
	end

	# reduce indent level
	def redind(i=1)
		return if (@indlevel - i < 0)
		@indlevel -= i
	end

	# dedcrease indent level
	def decind(i=1)
		redind(i)
	end

end