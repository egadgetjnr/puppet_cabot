require 'spec_helper'

describe 'cabot::api' do
  Puppet::Util::Log.level = :warning
  Puppet::Util::Log.newdestination(:console)

  let(:pre_condition) {[
    @cabot_common
  ]}
  
  context "ubuntu" do
  	let(:facts) { {
	  	:osfamily 					      => 'Debian',
	  	:operatingsystem 			    => 'Ubuntu',
	  	:lsbdistid					      => 'Ubuntu',
	  	:lsbdistcodename 			    => 'precise',
	  	:operatingsystemrelease 	=> '12.04',
	  	:concat_basedir  			    => '/tmp', # Concat	 
	  } }
	  
    let(:params) { {
      :password => 'password',
    } }
	  
	  context "ubuntu_defaults" do	  	    
		  it { should compile.with_all_deps }
	  
      it { should contain_class('cabot::api') }
        
      it { should contain_file('/etc/cabot') }
      it { should contain_file('/etc/cabot/puppet_api.yaml') }
      it { should contain_file('/etc/cabot/get_user_hash.py') }
        
      it { should contain_package('rest-client') }
    end
  end
end
