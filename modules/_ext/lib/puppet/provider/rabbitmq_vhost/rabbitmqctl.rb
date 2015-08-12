Puppet::Type.type(:rabbitmq_vhost).provide :rabbitmqctl do
	
	commands :rabbitmqctl => '/usr/sbin/rabbitmqctl'
	
	def create
		rabbitmqctl '-q',  'add_vhost', @resource[:name]
	end
	
	def destroy
		rabbitmqctl '-q',  'delete_vhost', @resource[:name]
	end
	
	def exists?
		! ( rabbitmqctl '-q',  'list_vhosts' ).split("\n").grep( @resource[:name] ).empty?
	end
	
	def self.instances
		Puppet.debug "Running self.instances method"
		instances = []
		get_vhosts.map do |vhost|
			new( :name => vhost.to_s, :ensure => :present )
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
