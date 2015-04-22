require 'beaker-rspec'
require 'pry'

hosts.each do |host|
  # Using box with pre-installed Puppet !
    
  # ON PROVISION ONLY !		on host, "apt-get update"
end

RSpec.configure do |c|
	# Project root
    proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

	# Readable test descriptions
  	c.formatter = :documentation

	# Configure all nodes in nodeset
  	c.before :suite do
  		# Install dependencies
  		 hosts.each do |host|
	       on host, puppet('module', 'install', 'puppetlabs-git'), { :acceptable_exit_codes => [0,1] }
	       		#on host, puppet('module','install','puppetlabs-vcsrepo'), { :acceptable_exit_codes => [0,1] }	       
	       on host, puppet('module','install','puppetlabs-ruby'), { :acceptable_exit_codes => [0,1] }
	       on host, puppet('module', 'install', 'stankevich-python'), { :acceptable_exit_codes => [0,1] }
	       on host, puppet('module','install','puppetlabs-nodejs'), { :acceptable_exit_codes => [0,1] }
	       		#on host, puppet('module','install','puppetlabs-apt'), { :acceptable_exit_codes => [0,1] } 	   
	       on host, puppet('module', 'install', 'thomasvandoren-redis'), { :acceptable_exit_codes => [0,1] }
	       		#on host, puppet('module','install','puppetlabs-gcc'), { :acceptable_exit_codes => [0,1] }
	       		#on host, puppet('module', 'install', 'puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
	       		# WGET !!
	       		
	       on host, puppet('module', 'install --ignore-dependencies', 'puppetlabs-postgresql'), { :acceptable_exit_codes => [0,1] }   	
	       		on host, puppet('module','install','puppetlabs-concat'), { :acceptable_exit_codes => [0,1] }
	       
	       #on host, puppet('module','install','puppetlabs-apache'), { :acceptable_exit_codes => [0,1] }
	     end
  	
		# Install module
		puppet_module_install(:source => proj_root, :module_name => 'cabot')
  end
end



