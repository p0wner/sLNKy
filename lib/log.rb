# class to hold log records
class Log < Array

	def write_logfile(filename, mode=:append)

		case mode
		when "a+", :append
			mode = "a+"

		when "w+", :overwrite
			mode = "w+"

		when :new

			if Dir::entries('.').include?(filename)
				d = DateTime::now
				suffix = [d.year, d.mon, d.mday, d.hour, d.min, d.sec].join('_')
				filename += suffix
			end

		end

		File::open(filename, mode) do |logfile|
			self.each { |record| logfile.puts(record.to_csv) }
		end

	end

	def get_lnknames()

		lnknames = []
		self.each{|record| lnknames << record.lnkname}
		return lnknames

	end

	def get_shares()

		shares = []
		self.each{|record| shares << record.share}
		return shares

	end

	def get_unique_field_values(field)

		field = symbolize(field)

		values = []
		self.each do |record|
			value = record.instance_variable_get(field)
			values << value unless values.include?(value)
		end

		return values.sort.uniq

	end

	def get_records_where(field,value)

		field = symbolize(field)

		hits = Log.new()

		self.each do |record|
			if record.instance_variable_get(field) == value
				hits << record
			end
		end

		return hits

	end

	def symbolize(field)
		unless field =~ /\@/ and field.class == Symbol
			field = ("@" + field).to_sym
		end
		return field
	end

end