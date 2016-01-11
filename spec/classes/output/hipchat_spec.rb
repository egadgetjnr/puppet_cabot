require 'spec_helper'

describe 'cabot::output::hipchat' do
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
        :room    => 'alertRoom',
        :api_key => 'myKey',
      } }

      it { expect(exported_resources).to contain_ini_setting("cabot_development_HIPCHAT_URL").with_value('https://api.hipchat.com/v1/rooms/message') }
      it { expect(exported_resources).to contain_ini_setting("cabot_development_HIPCHAT_ALERT_ROOM").with_value('alertRoom') }
      it { expect(exported_resources).to contain_ini_setting("cabot_development_HIPCHAT_API_KEY").with_value('myKey') }
    end    
  end
end
