# Function to automate cleaning of dropped malicious LNK files.
def clean_lnks(config)

	# create log to contain records
	config.dropped_lnks = Log.new()

	# convenience variable
	dropped_lnks = config.dropped_lnks

	# open the log file and create records
	File.open(config.lnk_logfile).each do |record|

		# split the record as CSV and remote double quotes
		record = record.split(',')
			.map{|f| f.gsub('"','')}

		# Add the record to the log list
		dropped_lnks << LogRecord.new(record[0],
			record[1],
			record[2],
			record[3],
			record[4],
			record[5])

	end

	[139, 445].each do |port|


		# Get all hosts
		hosts = dropped_lnks.get_records_where("port", port.to_s)

		hosts = hosts.get_unique_field_values("host")

		# Target all lnks dropped on various shares for a host
		# allows for a single SMB session initialization
		hosts.each do |host|

			# Get records of dropped links by host
			records = dropped_lnks.get_records_where("host", host)

			# Socket parameters for sclient
			sock_params = {PeerHost: host, PeerPort: port}

			# Connect and authenticate to host
			sclient = generate_smb_client(host, port, config.creds)

			# Mount each share and delete relevant lnks
			# In theory, there should be only a single dropped lnk
			records.each do |record|

				# generate_smb_client will return nil if auth fails
				if sclient

					# mount the share
					success = sclient.safe_connect(record.share)

					next unless success

					# get list of files on share
					listing, emessage = sclient.get_file_listing()

					if ! listing

						$prompt.symbol = '!'
						$prompt.alert("Share listing failure (#{record.share}): " + emessage.gsub(/.+:/,''))

						if emessage =~ /STATUS_NETWORK_NAME_DELETED|STATUS_ACCESS_DENIED/
							$prompt.incind
							$prompt.alert("Did you forget to provide credentials?")
							$prompt.decind
						end

						$prompt.reset!(:symbol)

						next
					end

					# delete the lnk if found
					if listing.include?(record.lnkname)

						begin

							$prompt.alert("Deleting LNK: #{record.to_unc}")
							sclient.delete(record.lnkname)

						rescue Rex::Proto::SMB::Exceptions::ErrorCode => error

							$prompt.incind
							$prompt.symbol = '!'
							$prompt.alert("Error deleting LNK!: #{error.message.gsub(/^.+:/,'')}")
							$prompt.decind
							$prompt.reset!(:symbol)

						end

					# alert user if lnk is not found
					else
						$prompt.symbol = '!'
						$prompt.alert("LNK Not Found: #{record.to_unc}")
						$prompt.reset!(:symbol)
					end

				# alert user of failed authentication
				else

					puts "Authentication failed! Moving to next record."

				end

				# disconnect the share
				sclient.disconnect(record.share)

			end

		end

	end

end
