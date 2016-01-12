require 'spec_helper'

describe 'cabot::output::twilio' do
  Puppet::Util::Log.level = :warning
  Puppet::Util::Log.newdestination(:console)
  
  let(:pre_condition) {[
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
    }
    "
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
	  	      
    context "default" do                 
      let(:params) { {
        :account_sid     => 'Me',
        :auth_token      => 'Secret',
        :outgoing_number => '123456789',
      } }

      it { should contain_ini_setting("cabot_development_TWILIO_ACCOUNT_SID").with_value('Me') }
      it { should contain_ini_setting("cabot_development_TWILIO_AUTH_TOKEN").with_value('Secret') }
      it { should contain_ini_setting("cabot_development_TWILIO_OUTGOING_NUMBER").with_value('123456789') }
      # Exported Resource version - it { expect(exported_resources).to contain_ini_setting("cabot_development_TWILIO_ACCOUNT_SID").with_value('Me') }
      # Exported Resource version - it { expect(exported_resources).to contain_ini_setting("cabot_development_TWILIO_AUTH_TOKEN").with_value('Secret') }
      # Exported Resource version - it { expect(exported_resources).to contain_ini_setting("cabot_development_TWILIO_OUTGOING_NUMBER").with_value('123456789') }
    end    
  end
end
