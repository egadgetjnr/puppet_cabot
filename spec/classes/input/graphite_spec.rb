require 'spec_helper'

describe 'cabot::input::graphite' do
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
      admin_password   => 'password',
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
        :host => 'graph.example.com',
        :port => 80,
      } }
            
      it { should contain_ini_setting("cabot_development_GRAPHITE_API").with_value('http://graph.example.com:80/') }
      it { should contain_ini_setting("cabot_development_GRAPHITE_FROM").with_value('-10min') }
      it { should contain_ini_setting("cabot_development_GRAPHITE_USER").with_ensure('absent') }
      it { should contain_ini_setting("cabot_development_GRAPHITE_PASS").with_ensure('absent') }
      # Exported Resource version - it { expect(exported_resources).to contain_ini_setting("cabot_development_GRAPHITE_API").with_value('http://graph.example.com:80/') }
      # Exported Resource version - it { expect(exported_resources).to contain_ini_setting("cabot_development_GRAPHITE_FROM").with_value('-10min') }
      # Exported Resource version - it { expect(exported_resources).to contain_ini_setting("cabot_development_GRAPHITE_USER").with_ensure('absent') }
      # Exported Resource version - it { expect(exported_resources).to contain_ini_setting("cabot_development_GRAPHITE_PASS").with_ensure('absent') }
    end
	  
	  context "unauth" do	  	    		    
      let(:params) { {
        :host => 'graph.example.com',
        :port => 80,
        :from => '-1hour',
      } }

      it { should contain_ini_setting("cabot_development_GRAPHITE_API").with_value('http://graph.example.com:80/') }
      it { should contain_ini_setting("cabot_development_GRAPHITE_FROM").with_value('-1hour') }
      it { should contain_ini_setting("cabot_development_GRAPHITE_USER").with_ensure('absent') }
      it { should contain_ini_setting("cabot_development_GRAPHITE_PASS").with_ensure('absent') }
      # Exported Resource version - it { expect(exported_resources).to contain_ini_setting("cabot_development_GRAPHITE_API").with_value('http://graph.example.com:80/') }
      # Exported Resource version - it { expect(exported_resources).to contain_ini_setting("cabot_development_GRAPHITE_FROM").with_value('-1hour') }
      # Exported Resource version - it { expect(exported_resources).to contain_ini_setting("cabot_development_GRAPHITE_USER").with_ensure('absent') }
      # Exported Resource version - it { expect(exported_resources).to contain_ini_setting("cabot_development_GRAPHITE_PASS").with_ensure('absent') }
    end
    
    context "auth" do                 
      let(:params) { {
        :host     => 'graph.example.com',
        :port     => 80,
        :username => 'user',
        :password => 'secret',
      } }

      it { should contain_ini_setting("cabot_development_GRAPHITE_API").with_value('http://graph.example.com:80/') }
      it { should contain_ini_setting("cabot_development_GRAPHITE_FROM").with_value('-10min') }
      it { should contain_ini_setting("cabot_development_GRAPHITE_USER").with_value('user') }
      it { should contain_ini_setting("cabot_development_GRAPHITE_PASS").with_value('secret') }
      # Exported Resource version - it { expect(exported_resources).to contain_ini_setting("cabot_development_GRAPHITE_API").with_value('http://graph.example.com:80/') }
      # Exported Resource version - it { expect(exported_resources).to contain_ini_setting("cabot_development_GRAPHITE_FROM").with_value('-10min') }
      # Exported Resource version - it { expect(exported_resources).to contain_ini_setting("cabot_development_GRAPHITE_USER").with_value('user') }
      # Exported Resource version - it { expect(exported_resources).to contain_ini_setting("cabot_development_GRAPHITE_PASS").with_value('secret') }
    end    
  end
end
