require 'etc'
require 'fileutils'

Puppet::Type.type(:rabbitmq_cookie).provide :rabbitmqctl do
	
	commands :rabbitmqctl => '/usr/sbin/rabbitmqctl' 
	commands :service => '/etc/init.d/rabbitmq-server'
	
	def create
		Puppet.debug "Service returned >%s<" % rabbitmq_running?.to_s
		
		# Stop the service
		service 'stop' if rabbitmq_running?
		sleep 2
		
		if system("ps axu | grep beam | grep -vq grep") then
			Puppet.warning "beam process still running after attempt to stop \"rabbitmq-server\"."
		end
		
		# Write the cookie
		f = File.open( "#{ @resource[:datadir] }/.erlang.cookie", 'w' )
		f.write( @resource[:name] )
		
		# Set permissions
		f.chmod(0400)
		f.chown( Etc.getpwnam( @resource[:proc_user] ).uid, 
			Etc.getgrnam( @resource[:proc_user] ).gid )
		f.close
		
		FileUtils.rm_r "#{ @resource[:datadir] }/mnesia" if File.exists?( "#{ @resource[:datadir] }/mnesia" )
		
		Puppet.notice "Virginity restored. Can join a cluster."		
	end
	
	def destroy
		# Stop the service
		service 'stop' if rabbitmq_running?
		sleep 2
		
		if system("ps axu | grep beam | grep -vq grep") then
			Puppet.warning "beam process still running after attempt to stop \"rabbitmq-server\"."
		end
		
		File.delete( "#{ @resource[:datadir] }/.erlang.cookie" )
	end
	
	def exists?
		file = "#{ @resource[:datadir] }/.erlang.cookie"
		File.exists?( file ) and File.open( file, 'r' ){|f| f.read} == @resource[:name]
	end
	
	# Helper methods
	
	def rabbitmq_running?
		system('/etc/init.d/rabbitmq-server status >/dev/null')
	end
	
end 
