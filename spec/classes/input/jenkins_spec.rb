require 'spec_helper'

describe 'cabot::input::jenkins' do
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
      :puppetversion            => '3.8.5',
      :virtualenv_version       => '12.0', # Should not matter for spec tests (python dependency)
	  } }
	  
    context "default" do    
      let(:params) { {
        :host     => 'jenkins.example.com',
        :port     => 80,
        :username => 'user',
        :password => 'secret',
      } }
            
      it { should contain_ini_setting("cabot_development_JENKINS_API").with_value('http://jenkins.example.com:80/') }
      it { should contain_ini_setting("cabot_development_JENKINS_USER").with_value('user') }
      it { should contain_ini_setting("cabot_development_JENKINS_PASS").with_value('secret') }
      # Exported Resource version - it { expect(exported_resources).to contain_ini_setting("cabot_development_JENKINS_API").with_value('http://jenkins.example.com:80/') }
      # Exported Resource version - it { expect(exported_resources).to contain_ini_setting("cabot_development_JENKINS_USER").with_value('user') }
      # Exported Resource version - it { expect(exported_resources).to contain_ini_setting("cabot_development_JENKINS_PASS").with_value('secret') }
    end
  end
end
