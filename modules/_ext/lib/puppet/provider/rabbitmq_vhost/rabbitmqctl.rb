Puppet::Type.type(:rabbitmq_vhost).provide :rabbitmqctl do
	
	commands :rabbitmqctl => '/usr/sbin/rabbitmqctl'
	
	def create
		rabbitmqctl '-q',  'add_vhost', @resource[:name]
	end
	
	def destroy
		rabbitmqctl '-q',  'delete_vhost', @resource[:name]
	end
	
	def exists?
		@property_hash[:ensure] == :present
	end
	
	# self.instances
	# -------------------------
	# Query the system for existing resource instances. For each resource,
	# initialise an instance of Puppet::Type::Rabbitmq_vhost::ProviderRabbitmqctl
	# by calling new()
	
	def self.instances
		Puppet.debug "Running self.instances method for %s" % self
		instances = []
		get_vhosts.map do |vhost|
			new( :name => vhost.to_s, :ensure => :present )
		end
	end
	
	# self.prefetch
	# -------------------------
	# The argument is a hash. The keys are of the resources' names from catalog.
	# The values are catalog-based instances of Puppet::Type::Rabbitmq_vhost class.
	
	# Iterates though provider instances of resources already existing on the client.
	
	# If a resource of the same name exists in the catalog, the provider property
	# of this catalog resource gets the respective provider instance as its value.
	
	# @property_hash gets populated with the is-state for each existing resource
	# and is available to all instance methods.
	
	# If the 'namevar' of the resource type is 'name' (the default), 
	# it is unlikely that this method will need any changes, ever.
	
	def self.prefetch( resources )
		instances.each do |prov|
			if resource = resources[prov.name]
				resource.provider = prov
			end
		end
	end

	# Helper methods
	
	def self.get_vhosts
		begin
			( rabbitmqctl '-q',  'list_vhosts' ).split("\n")
		rescue => ex
			Puppet.warning "Could not prefetch vhosts. Exception:\n%s" % ex.to_s
			return []
		end
	end
	
end 
