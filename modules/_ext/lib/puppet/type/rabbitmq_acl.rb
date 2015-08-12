Puppet::Type.newtype(:rabbitmq_acl) do 
	ensurable
	
	desc 'Defines accesss control list for a combination of a virtual host(s) 
	and users on a RabbitMQ server to perform actions on its resources.
	'
	
	newparam(:name, :namevar=>'true') do
		desc 'A combination of user name and vhost to identify the ACL, user@vhost'
		
		validate do |value|
			unless value =~/(\w+)\@([\/\w]+)/
				raise ArgumentError, "%s is not a valid acl name, expecting user@vhost" % value
			end
		end
	end
	
	newproperty(:configure) do
		desc 'Regex matching RabbitMQ resources (exchanges and/or queues
		to which "configure" rights apply.
		'
		validate do |value|
			# TODO: validate a Regexp
		end
	end
	
	newproperty(:write) do
		desc 'Regex matching RabbitMQ resources (exchanges and/or queues
		to which "configure" rights apply.
		'
		validate do |value|
			# TODO: validate a Regexp
		end
	end
	
	newproperty(:read) do
		desc 'Regex matching RabbitMQ resources (exchanges and/or queues
		to which "configure" rights apply.
		'
		validate do |value|
			# TODO: validate a Regexp
		end
	end
end