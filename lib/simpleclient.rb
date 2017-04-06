require_relative 'alerts.rb'

# making methods easily accessible to simpleclient
class Rex::Proto::SMB::SimpleClient

	@@alerter = Alerts.new()

	def get_file_listing()

		return self.client.find_first('\\')
			.keys
			.delete_if{ |s| s =~ /^\.|^\$/i }, true

		rescue Rex::Proto::SMB::Exceptions::ErrorCode => error

			return false, error.message

	end

	def safe_connect(share_name)

		self.connect(share_name)
		return true

		rescue Rex::Proto::SMB::Exceptions::ErrorCode => error

			return false, error.message

	end

	def enumerate_browseable_shares()

		#  Connect to IPC share
		self.connect("IPC$")

		#### CREDIT TO METASPLOIT FOR THE FOLLOWING CODE ####
		shares = []

		# Perform smb transaction
		# NetShareEnum request
		# RAP command
		res = self.client.trans(
			"\\PIPE\\LANMAN",
			(
				[0x00].pack('v') +			# RAPOpcode		2 bytes
				"WrLeh\x00"   +				# ParamDesc 	6 bytes		Must be populated as WrLeH\x00
				"B13BWz\x00"  +				# DataDesc		VARIABLE	Determines InfoLevel; 3 values: 'B13' (InfoLevel: 0x0000), 'B13BWz' (InfoLevel: 0x0001), 'B13BWzWWWzB9B' (InfoLevel: 0x0002)
				[0x01, 65406].pack("vv")	# RAPParams		4 bytes		[InfoLevel,ReceiveBufferSize]
			)
		)

		# Parse NetShareEnum response
	    lerror, lconv, lentries, lcount = res['Payload']
	    	.to_s[
	    		res['Payload'].v['ParamOffset'],
	      		res['Payload'].v['ParamCount']
	    	].unpack("v4")

	    data = res['Payload'].to_s[
	      res['Payload'].v['DataOffset'],
	      res['Payload'].v['DataCount']
	    ]

	    0.upto(lentries - 1) do |i|

	      sname,tmp = data[(i * 20) +  0, 14].split("\x00")
	      stype     = data[(i * 20) + 14, 2].unpack('v')[0]
	      scoff     = data[(i * 20) + 16, 2].unpack('v')[0]
	      scoff 	-= lconv if lconv != 0
	      scomm,tmp = data[scoff, data.length - scoff].split("\x00")
	      shares << Share.new(sname, stype, scomm)

	    end
		######################################################

		self.disconnect("IPC$")

		# Might want to revisit this logic.
		# Could be benificial to only delete named pipes from share list
		# shares.delete_if { |s| s.name =~ /\$/ }

		return shares

	end

end