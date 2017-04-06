def bruteforce_shares(config, sclient, shares)

	host = sclient.socket.peerhost

	# shares should be an array of strings (share names)
	valid_shares = []

	shares.each do |s|

		outcome, emessage = sclient.safe_connect(s)

		if outcome
			sclient.disconnect(s)
			
			$prompt.alert("Adding #{s} to share list!", true, false)
			valid_shares << Share.new(s, 0, nil, host)
		else
			# $prompt.symbol = '!'
			# $prompt.alert("Invalid share: #{s} [FAILED] ", true, false)
			# 
			# puts emessage.gsub(/^.+: /,'')
			# ()
			# $prompt.reset!(:symbol)
			next
		end

	end

	valid_shares = nil if valid_shares == []

	if valid_shares

		# 

		# TODO: Write bruteforced shares to logs!
		$prompt.alert("Writing bruteforced share to logs", true, false)

		Dir::mkdir(config.logdir) unless Dir::entries('.').include?(config.logdir)
		Dir::chdir(config.logdir)

		File::open(config.brute_logfile,'a+') do |lfile|
			valid_shares.each {|s| lfile.puts(%["#{host}","#{s.name}"])}
		end

		# 

		Dir::chdir('..')

	end

	return valid_shares

end