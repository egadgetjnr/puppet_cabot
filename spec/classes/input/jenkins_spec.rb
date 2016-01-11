require 'spec_helper'

describe 'cabot::input::jenkins' do
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
        :host     => 'jenkins.example.com',
        :port     => 80,
        :username => 'user',
        :password => 'secret',
      } }
            
      it { expect(exported_resources).to contain_ini_setting("cabot_development_JENKINS_API").with_value('http://jenkins.example.com:80/') }
      it { expect(exported_resources).to contain_ini_setting("cabot_development_JENKINS_USER").with_value('user') }
      it { expect(exported_resources).to contain_ini_setting("cabot_development_JENKINS_PASS").with_value('secret') }
    end
  end
end
