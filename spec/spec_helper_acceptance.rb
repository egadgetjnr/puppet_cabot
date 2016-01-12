require 'beaker-rspec'
#require 'pry'

hosts.each do |host|
  # Using box with pre-installed Puppet !
end

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

	# Readable test descriptions
  c.formatter = :documentation

	# Configure all nodes in nodeset
  c.before :suite do

# TODO only on provision
    # Install dependencies
	  hosts.each do |host|	
      on host, "apt-get update"
         
	    on host, puppet('module', 'install', 'puppetlabs-postgresql'), { :acceptable_exit_codes => [0,1] }
	    on host, puppet('module', 'install', 'puppetlabs-gcc'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'puppetlabs-vcsrepo'), { :acceptable_exit_codes => [0,1] }  
      on host, puppet('module', 'install', 'stankevich-python'), { :acceptable_exit_codes => [0,1] }  
      on host, puppet('module', 'install', 'puppetlabs-apache'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'puppetlabs-nodejs'), { :acceptable_exit_codes => [0,1] }            
      on host, puppet('module', 'install', 'puppetlabs-git'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'puppetlabs-ruby'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'thomasvandoren-redis'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'puppetlabs-inifile'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'rodjek-logrotate'), { :acceptable_exit_codes => [0,1] }
    end
#END TODO only on provision
      	
		# Install module
	  puppet_module_install(:source => proj_root, :module_name => 'cabot')
  end
end



