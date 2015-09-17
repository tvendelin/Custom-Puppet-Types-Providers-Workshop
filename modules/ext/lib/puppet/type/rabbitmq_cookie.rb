Puppet::Type.newtype(:rabbitmq_cookie) do 
	ensurable
	require 'etc'
	
	desc 'Defines an Erlang cookie for RabbitMQ cluster.
	The cluster nodes must be set in /etc/rabbitmq/rabbitmq.config.
	
	IMPORTANT:
	
	Do not change it on a node instance that may have active connections
	and non-empty queues! Instead, disable publisher access, restart the service,
	and wait until the queues are empty and there are no more incoming connections to the host.
	
	Changing Erlang cookie here removes the node from any cluster it belongs to,
	removes all data from the management database, such as configured
	users and vhosts, and deletes all persistent messages.
	'
		
	newparam(:name) do
		
		desc "Cluster cookie for RabbitMQ server. Can be orbitrary string 
		of 8 characters or longer"
		
		validate do |val|
			if val.length < 8 then
				raise ArgumentError, "Cluster cookie must be at least 8 characters long, got >%s<" % val.length
			end
			
			if val =~/\s/ then
				raise ArgumentError, "Cluster cookie cannot contain space chars, got >%s<" % val
			end
		end
		
	end

	newparam(:proc_user) do
		desc 'System user running RabbitMQ server. Defaults to "rabbitmq"'
		validate do |val|
			return if val.nil?
			begin
				Etc.getpwnam(val)
			rescue
				raise ArgumentError, "User >%s< does not exist" % val
			end
		end
		
		defaultto 'rabbitmq'
	end
	
	newparam(:datadir) do
		
		desc 'Data directory for RabbitMQ server.
		Defaults to "/var/lib/rabbitmq-server"
		on Linux systems.
		'
		validate do |val|
			Puppet.debug "datadir is >%s<" % val
			return if val.nil?
      val =~ /^\/[\/\w]+/ or
        raise ArgumentError, "Expecting a directory path, got >%s< instead" % val
		end
		defaultto '/var/lib/rabbitmq'
	end
end
