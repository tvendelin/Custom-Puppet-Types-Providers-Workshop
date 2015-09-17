Puppet::Type.newtype(:rabbitmq_vhost) do 
	ensurable
	
	desc 'Defines a virtual host on a RabbitMQ server'
	
	newparam(:name) do
		desc 'The name of the virtual host'
		validate do |value|
			unless value =~/^[\/\w]+$/
				raise ArgumentError, "%s is not a valid virtual host name" % value
			end
		end
	end
end