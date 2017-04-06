def generate_file(config)

	unless config.lnk_outfile =~ /\.lnk$/
		config.lnk_outfile += '.lnk'
	end

	generate_malicious_lnk(config)
	$prompt.alert("Writing malicious LNK file to #{config.lnk_outfile}...",false)
	File.open(config.lnk_outfile,'w+') do |file|
		file.puts($template)
	end
	puts "done!"
	puts

end