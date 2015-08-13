require 'puppet/provider/rabbitmq'
require 'json'

Puppet::Type.type(:rabbitmq_policy).provide :rabbitmqctl, 
	{ :parent => Puppet::Provider::Rabbitmq } do
	
	commands :rabbitmqctl => '/usr/sbin/rabbitmqctl'
	
	mk_resource_methods
	
	def create
		Puppet.debug "Useless create method called. Flush will be used directly instead."	 
	end
	
	def destroy
		Puppet.debug "Useless create method called. Flush will be used directly instead."
	end
	
	def exists?
		@property_hash[:ensure] == :present
	end

	def self.instances
		Puppet.debug "Running self.instances method for %s" % self
		instances = []
		get_policies.map { |policy| new( policy ) }
	end
	
	def self.prefetch( resources )
		instances.each do |prov|
			if resource = resources[prov.name]
				resource.provider = prov
			end
		end
	end
	
	def flush
		if ! @property_hash.key?(:ensure) or @property_hash[:ensure] == :present
			# Creating or Modifying
			rabbitmqctl '-q', 'set_policy', '-p', 
				@resource[:vhost],
 				@resource[:name], 
 				@resource[:match], 
 				@resource[:policy].to_json, 
 				'--apply-to', @resource[:apply_to],
 				'--priority', @resource[:priority]
 		elsif @property_hash[:ensure] == :absent
			# Destroying
			rabbitmqctl '-q',  'clear_policy', @resource[:name]
 		end
	end
	
	# Helper methods
	
	def self.get_policies
		policies = []
		
		get_vhosts.each do |vhost|
			policies += get_policy_vhost(vhost)
		end
		
		return policies
	end
	
	def self.get_policy_vhost(vhost)
		policies = []
		( rabbitmqctl '-q', '-p', vhost, 'list_policies' ).split("\n").each do |p|
			( vhost, name, apply_to, match, policy, priority ) = p.split("\t")
	
			Puppet.debug "In list_policies:>#{[ vhost, name, apply_to, match, policy, priority ].join(',')}<"
	
			policies <<
				{	:vhost		=> vhost,
					:name		=> name,
					:apply_to	=> apply_to,
					:match		=> match,
					:policy		=> JSON.parse( policy ), 
					:priority	=> priority,
					:ensure		=> :present,
				}
		end
		return policies
	end
end 
