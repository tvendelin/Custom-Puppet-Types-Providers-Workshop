Puppet::Type.type(:rabbitmq_acl).provide :rabbitmqctl do
	
	commands :rabbitmqctl => '/usr/sbin/rabbitmqctl'
	
	mk_resource_methods
	
	def initialize(args={})
		# Get the user and the vhost out of composite name user@vhost
		args[:name]  =~/(\w+)\@([\/\w]+)/
		( @user, @vhost ) = [ $1, $2 ]
		
		# Proceed as usual
		super(args)
	end
	
	def create
		Puppet.debug 'Useless create method that still has to exist (with default ensure).'
	end
	
	def destroy
		@property_hash[:ensure] = :absent
	end
	
	def exists?
		@property_hash[:ensure] == :present
	end
	
	def self.instances
		Puppet.debug "Running self.instances method"
		inst = []
		
		get_vhosts.each do |vhost|
			get_permissions( vhost ).each do |user, configure, write, read|
				Puppet.debug "Got permissions: #{[vhost, user, configure, write, read].join(',')}"
				inst << new(
					:name			=> "#{user}@#{vhost}",
					:configure		=> configure,
					:write			=> write,
					:read			=> read,
					:ensure			=> :present 
				)
			end
		end
		return inst
	end
	
	def self.prefetch( resources )
		instances.each do |prov|
			Puppet.debug "Prefetch: #{[prov.name, prov.configure, prov.write, prov.read].join(',')}"
			if resource = resources[prov.name]
				resource.provider = prov
			end
		end
	end
	
	def flush
		debug "Flushing ACL for >%s< at vhost >%s<" % [@user, @vhost]
		
		if ! @property_hash.key?(:ensure)
			# Creating
			rabbitmqctl '-q',  'set_permissions', '-p', @vhost, @user, 
 				@resource[:configure], @resource[:write], @resource[:read]
		elsif @property_hash[:ensure] == :present
			# Modifying
			rabbitmqctl '-q',  'set_permissions', '-p', @vhost, @user, 
 				@property_hash[:configure], @property_hash[:write], @property_hash[:read]
 		elsif @property_hash[:ensure] == :absent
			# Destroying
			rabbitmqctl '-q',  'clear_permissions', '-p', @vhost, @user
 		end
	end
	
	
	# Helper methods
	
	def self.get_users
		users = []
		
		begin
			rawout = (rabbitmqctl '-q',  'list_users')
		rescue
			Puppet.debug "Could not prefetch RabbitMQ users. Exception:\n%s" % ex.to_s
			return []
		end
		
		rawout.split("\n").map do |entry|
			( user, taggs ) = entry.split("\t")
			taggs = taggs[1, taggs.length - 2 ].split(', ')
			users << { :name => user, :user => user, :ensure => :present, :taggs => taggs }
		end
		return users
	end
	
	def self.get_vhosts
		begin
			( rabbitmqctl '-q',  'list_vhosts' ).split("\n")
		rescue => ex
			Puppet.debug "Could not prefetch RabbitMQ vhosts. Exception:\n%s" % ex.to_s
			return []
		end
	end
	
	def self.get_permissions ( vhost )
		( rabbitmqctl '-q',  'list_permissions', '-p', vhost ).split("\n").map do |p| 
			p.split(/\s+/)
		end
	end
end 








