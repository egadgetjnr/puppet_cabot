require 'spec_helper_acceptance'

describe 'cabot class' do
	describe 'running puppet code' do
    	it 'should work with no errors' do
      		pp = <<-EOS
      		  class { '::cabot': 
              install_postgres       => true,
              install_postgres_devel => true,
              install_git            => true,
              install_ruby           => true,
              install_python         => true,
              install_nodejs         => true,
              install_redis          => true,
              install_apache         => true,
      		  } 		
      		EOS

      		# Run it twice and test for idempotency
      		apply_manifest(pp, :catch_failures => true)
      		
      		expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
      	end
    end
end