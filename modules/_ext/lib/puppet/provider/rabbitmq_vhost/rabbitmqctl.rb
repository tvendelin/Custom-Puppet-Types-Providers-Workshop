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
	
end 
