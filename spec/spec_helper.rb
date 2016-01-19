require 'rubygems'
require 'puppetlabs_spec_helper/module_spec_helper'
require 'helpers/exported_resources'

fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))
  
RSpec.configure do |c|
  c.hiera_config = File.join(fixture_path, 'hiera/hiera.yaml')
  
  c.before do
    # avoid "Only root can execute commands as other users"
    # required by Postgres dependency
    Puppet.features.stubs(:root? => true)
  end
end

# Common code for (most) spec tests
RSpec.configure do |c|
  c.before do 
    @cabot_common =
      "class { 'cabot':
        install_postgres => true,
        setup_db         => true,
        install_gcc      => true,
        install_git      => true,
        install_ruby     => true,
        install_python   => true,
        install_nodejs   => true,
        setup_logrotate  => true,
        install_redis    => true,
        install_apache   => true,
        setup_apache     => true,   
        admin_password   => 'password',
        admin_address    => 'cabot@example.com',
        environment      => 'development',
      }
      "
  end
end