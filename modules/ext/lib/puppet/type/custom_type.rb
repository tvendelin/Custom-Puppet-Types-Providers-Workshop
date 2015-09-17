Puppet::Type.newtype(:custom_type) do 
	ensurable do
		newvalue(:present) do
			Puppet.info "%s: Running [%s] instance method" % [self.class, __method__]
			provider.create
		end
		
		newvalue(:absent) do
			Puppet.info "%s: Running [%s] instance method" % [self.class, __method__]
			provider.destroy
		end
		
		
	end
	
	desc 'A dummy Puppet resource type that only generates log messages
	'
	
	newparam(:name, :namevar=>'true') do
		desc 'A parameter that is set to be namevar, that is, to identify the resource'
		
		validate do |value|
			Puppet.info "%s: Running [%s] instance method, input is >%s<" % [self.class, __method__, value]
			unless value =~/^\w+$/
				raise ArgumentError, "%s is not a valid custom_name" % value
			end
		end
	end
	
	newproperty(:property_string1) do
		desc 'A property (that is, something that can be modified on the client)
		whose value is just a plain string
		'
		validate do |value|
			Puppet.info "%s: Running [%s] instance method, input is >%s<" % [self.class, __method__, value]
			unless value =~/^[ \w]+$/
				raise ArgumentError, "%s is not a valid property_string1" % value
			end
		end
		
		def insync?(is)
			Puppet.info "%s: Running [%s] instance method" % [self.class, __method__]
			Puppet.info "is-state:     >%s<" % is
			Puppet.info "should-state: >%s<\n" % should
			
			is == should
		end
	end

	newproperty(:property_string2) do
		desc 'A property (that is, something that can be modified on the client)
		whose value is just a plain string
		'
		validate do |value|
			Puppet.info "%s: Running [%s] instance method, input is >%s<" % [self.class, __method__, value]
			unless value =~/^[ \w]+$/
				raise ArgumentError, "%s is not a valid property_string2" % value
			end
		end
		
		defaultto 'default_property_string2'
		
		def insync?(is)
			Puppet.info "%s: Running [%s] instance method" % [self.class, __method__]
			Puppet.info "is-state:     >%s<" % is
			Puppet.info "should-state: >%s<\n" % should
			
			is == should
		end
	end

	newproperty(:property_array1, :array_matching => :all) do
		desc 'A property whose value is an array
		'
		validate do |value|
			Puppet.info "%s: Running [%s] instance method, input is >%s<" % [self.class, __method__, value]
			unless value =~/^[ \w]+$/
				raise ArgumentError, "%s is not a valid value or element of property_array1" % value
			end
		end
		
		munge do |value|
			return_value = value.downcase
			Puppet.info "%s: Running [%s] instance method, input: >%s<, output: >%s<" % 
				[self.class, __method__, value, return_value]
			return value.downcase
		end
		
		defaultto %w[ JavaScript Haskell Smalltalk ]
		
		def insync?(is)
			Puppet.info "%s: Running [%s] instance method" % [self.class, __method__]
			Puppet.info "is-state:     >%s<" % is.join(',')
			Puppet.info "should-state: >%s<\n" % should.join(',')
			
			is.sort == should.sort
		end
		
		def should_to_s(newvalue)
    		'[' + [newvalue].flatten.map{|x| "'#{x}'"}.join(',') + ']'
  		end
	end
	
	def refresh
		provider.refresh_me
	end
end







