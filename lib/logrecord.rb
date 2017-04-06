# objects represent log records
class LogRecord

	attr_accessor :host, :port, :share, :lnkname, :droptime, :authenticated, :bruteforced

	def initialize(host=nil,
				port=nil,
				share=nil,
				lnkname=nil,
				droptime=nil,
				authenticated=false,
				bruteforced=false)

		@host = host
		@port = port
		@share = share
		@lnkname = lnkname
		@droptime = droptime
		@authenticated = authenticated
		@bruteforced = bruteforced

	end

	def to_unc(type=:lnk)

		if type == :lnk
			return %[\\\\#{@host}\\#{@share}\\#{@lnkname}]

		elsif type == :share_bruteforce
			return %[\\\\#{@host}\\#{@share}]

		end

	end

	def to_csv(type=:lnk)

		if type == :lnk
			# Dropped LNK log record
			return %["#{@host}","#{@port}","#{@share}","#{@lnkname}","#{@authenticated}","#{@bruteforced}","#{droptime}"]

		elsif type == :share_bruteforce
			# Bruteforced share log record
			return %["#{@host}","#{@port}","#{@share}","#{@authenticated}","#{@bruteforced}"]
			
		end

	end

end