class Puppet::Provider::Rabbitmq < Puppet::Provider 
	
	def self.execute( command, arguments = {:failonfail => true, :combine => false} )
		Puppet.debug "Overriding self.execute with :combine => false (separating stdout and stderr)"
		super( command, arguments )
	end
	
	def self.get_users
		users = []
		
		begin
			rawout = (rabbitmqctl '-q',  'list_users')
		rescue => ex
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
end
