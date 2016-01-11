require 'spec_helper_acceptance'

describe 'cabot class' do
	describe 'installation' do
    	it 'should work with no errors' do
    		pp = <<-EOS
    		  class { '::cabot': 
            install_postgres => true,
            setup_db         => true,
            install_gcc      => true,
            install_git      => true,
            install_ruby     => true,
            install_python   => true,
            install_nodejs   => true,
            setup_logrotate  => false,    # BUG !!
            install_redis    => true,
            install_apache   => true,
            setup_apache     => true,  
    		  } 		
    		EOS

    		# Run it twice and test for idempotency
    		apply_manifest(pp, :catch_failures => true)
    		
    		expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    		
        # Test running service ?
    	end
  end
  
  describe 'plugins' do
    pp = <<-EOS
      cabot::input::graphite (
        host => 'localhost',
        port => '80',
      }
    EOS
    
    # Test configuration file?
    
    # Test running service ?
  end
end