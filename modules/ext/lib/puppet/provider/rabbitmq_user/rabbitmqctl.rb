require 'json'
require 'puppet/provider/rabbitmq' 

Puppet::Type.type(:rabbitmq_user).provide :rabbitmqctl, 
	{ :parent => Puppet::Provider::Rabbitmq } do
	
	commands :rabbitmqctl => '/usr/sbin/rabbitmqctl'
	commands :curl => '/usr/bin/curl'
	
	mk_resource_methods
	
	def create
		rabbitmqctl '-q',  'add_user', @resource[:name], @resource[:password]
		rabbitmqctl '-q',  'set_user_tags', @resource[:user], @resource[:taggs]
	end
	
	def destroy
		rabbitmqctl '-q',  'delete_user', @resource[:name]
	end
	
	def exists?
		@property_hash[:ensure] == :present
	end
	
	def self.instances
		get_users.map{ |user| new( user ) }		
	end
	
	def self.prefetch( resources )
		instances.each do |prov|
			if resource = resources[prov.user]
				resource.provider = prov
			end
		end
	end
	
	# Getters and setters for resource properties
	
	def password
		begin
			r = curl '-s', '-u', "#{@resource[:name]}:#{@resource[:password]}",
				"http://localhost:#{@resource[:mgmt_port]}/api/whoami"
			debug r
		rescue
			raise "Management plugin not reachable at localhost:%s" % @resource[:mgmt_port]
		end
		rh = JSON.parse r
		
		if( rh.key?(:name) and rh[:name] == @property_hash[:name] )
			return @resource[:password]
		end
		
		if ( rh['error'] == 'not_authorised' and rh['reason'] == 'Not management user' )
			return @resource[:password]
		else
			return ''
		end
	end
	
	def password=(pw)
		rabbitmqctl '-q',  'change_password', @resource[:name], @resource[:password]
	end
	
	def taggs
		@property_hash[:taggs]
	end
	
	def taggs=(val)
		rabbitmqctl '-q',  'set_user_tags', @resource[:user], val
	end
	
	# Helper method(s) moved to the 'class-in-the-middle'
	
end 