Puppet::Type.newtype(:rabbitmq_policy) do 
	ensurable
	
	desc 'Manages RabbitMQ "policies" on a node or cluster'
		
	newparam(:name) do
		desc 'The human-readable name of the policy, characters [a-zA-Z0-9_] allowed'
		validate do |value|
			unless value =~/^\w+/
				raise ArgumentError, 
					"Invalid policy name. Only characters [a-zA-Z0-9_] allowed, got >%s<" % value
			end
		end
	end
	
	newproperty(:vhost) do
		desc 'A RabbitMQ virtual host the policy applies to. Defaults to "/"'
		
		defaultto '/'
		
		validate do |value|
			unless value =~/^[\/\w]+/
				raise ArgumentError, 
					"Invalid vhost. Only characters [\/a-zA-Z0-9_] allowed, got >%s<" % value
			end
		end
	end
	
	newproperty( :policy ) do
		desc 'RabbitMQ policy definition, must be a valid JSON string. 
		Make sure to use double quotes for strings. Handled as a hash internally.
		'
		
		validate do |val|
			begin
				JSON.parse(val)
			rescue => ex
				raise ArgumentError, "Invalid JSON string: %s" % ex.to_s
			end
		end
		
		munge do |val|
			JSON.parse(val)
		end
		
		def is_to_s(oldvalue)
    		oldvalue.to_json
  		end
		
		def should_to_s(newvalue)
    		newvalue.to_json
  		end
	end
	
	newproperty(:match) do
		desc 'A regex matching a RabbitMQ resorce (i.e., an exchange or a queue)'
		
		validate do |val|
			# Must be Regex
		end
	end
	
	newproperty(:priority) do
		desc 'A priority for this policy, an integer.'
		
		validate do |val|
			if val.to_s !~/^\d+$/
				raise ArgumentError, "Priority must be integer-like string, got >%s<" % val.to_s
			end
		end
		
		defaultto 0
	end
	
	newproperty(:apply_to) do
		desc 'RabbitMQ resource type the policy applies to.
		Possible values are "all", "queues" or "exchanges"'
		
		validate do |val|
			if( val == 'all' or val == 'queues' or val == 'exchanges' )
				return true
			end
			raise ArgumentError, 
				"apply_to must be one of: 'all', 'queues' or 'exchanges', got >%s<" % val.to_s
		end
		
		defaultto 'all'
	end
	
	
end


















