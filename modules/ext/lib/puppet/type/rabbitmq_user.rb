Puppet::Type.newtype(:rabbitmq_user) do 
	ensurable
	
	desc "RabbitMQ user configured locally"
	
	newparam(:user, :namevar=>'true') do
		desc 'The name of a RabbitMQ user'
		
		validate do |val|
			unless val =~/^\w+$/
				raise ArgumentError, "%s is not a valid RabbitMQ user name" % val
			end
		end
	end
	
	newproperty(:password) do
		desc "A RabbitMQ user password"
		
		validate do |val|
			unless val.match(/^\S{8,}$/)
				raise ArgumentError, "Password is non-conformant \
					(must contain at least 8 non-space characters)" % val
			end
		end
		
		# Overriding stringification methods for log messages
		def is_to_s(value)
			'*****'
		end
		
		def should_to_s(value)
			'*****'
		end	
	end
	
 	newparam(:mgmt_port) do
		desc "A RabbitMQ management plugin port"
		validate do |val|
			unless val.match(/^\d{4,5}$/)
				raise ArgumentError, "Expecting a TCP port number, got >%s<" % val
			end
		end
		defaultto '15672' 
	end
	
 	newproperty(:taggs, :array_matching => :all) do
 		
 		desc 'An array of user tags. "management", "policymaker", "monitoring" 
 		and "administrator" tags each have a special meaning in RabbitMQ management plugin.
 		'
  		
  		validate do |val|
 			# val is NOT an array, but rather an element of one
 			if val !~/^\w+$/
 				raise ArgumentError, "%s is not a valid RabbitMQ user tag" % tag
 			end
  		end
  		
 		def insync?(is)
 			Puppet.debug 'Insyncing taggs...'
 			Puppet.debug "IS state is >#{is.sort.join(',')}<"
 			Puppet.debug "SH state is >#{should.sort.join(',')}<"
 			
 			return true if( is.sort == should.sort )
 			
 			Puppet.debug "Not in sync: taggs"
 			return false
 		end
 		
 		def should_to_s(value)
			"['" + [value].flatten.join("', '") + "'\]"
		end	
 	end
	
end
