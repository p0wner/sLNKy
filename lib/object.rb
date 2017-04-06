class Object

	def get_instance_variables_table()

		rows = []
		table = Terminal::Table.new()
		table.headings = ['Instance Variable', 'Object']
		table.title = "#{self}: Instance Vairables"

		self.instance_variables.each do |iv|

			rows << [iv.to_s,self.instance_variable_get(iv)]
			
		end

		table.rows = rows

		return table

	end

	def get_methods_table()

		mlists = {
			methods: [],
			private: [],
			protected: [],
			public: []
		}

		self.methods.sort.each {|m| mlists[:methods] << m}
		self.private_methods.sort.each  {|m| mlists[:private] << m}
		self.protected_methods.sort.each {|m| mlists[:protected] << m}
		self.public_methods.sort.each  {|m| mlists[:public] << m}

		mlists.delete_if {|k,v| v == []}

		lengths = []
		headings = ['#']

		mlists.each do |k,v|
			headings << k.to_s.gsub('_',' ').capitalize
			lengths << v.length
		end

		max_len = lengths.uniq.sort.last

		table = Terminal::Table.new()
		table.headings = headings
		table.title = "#{self}: Methods"

		rows = []
		max_len.times do |n|

			row = []

			row << n
			mlists.each { |k,v|	row << mlists[k][n] }

			rows << row

		end

		table.rows = rows

		return table

	end

end