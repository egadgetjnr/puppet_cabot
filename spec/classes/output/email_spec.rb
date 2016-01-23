require 'spec_helper'

describe 'cabot::output::email' do
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
	  	  
	  context "unauth" do	  	    		    
      let(:params) { {
        :host => 'mail.example.com',
        :port => 25,
      } }

      it { should contain_ini_setting("cabot_development_SES_HOST").with_value('mail.example.com') }
      it { should contain_ini_setting("cabot_development_SES_PORT").with_value(25) }
      it { should contain_ini_setting("cabot_development_SES_USER").with_ensure('absent') }
      it { should contain_ini_setting("cabot_development_SES_PASS").with_ensure('absent') }
      # Exported Resource version - it { expect(exported_resources).to contain_ini_setting("cabot_development_SES_HOST").with_value('mail.example.com') }
      # Exported Resource version - it { expect(exported_resources).to contain_ini_setting("cabot_development_SES_PORT").with_value(25) }
      # Exported Resource version - it { expect(exported_resources).to contain_ini_setting("cabot_development_SES_USER").with_ensure('absent') }
      # Exported Resource version - it { expect(exported_resources).to contain_ini_setting("cabot_development_SES_PASS").with_ensure('absent') }
    end
    
    context "auth" do                 
      let(:params) { {
        :host     => 'mail.example.com',
        :port     => 25,
        :username => 'user',
        :password => 'secret',
      } }

      it { should contain_ini_setting("cabot_development_SES_HOST").with_value('mail.example.com') }
      it { should contain_ini_setting("cabot_development_SES_PORT").with_value(25) }
      it { should contain_ini_setting("cabot_development_SES_USER").with_value('user') }
      it { should contain_ini_setting("cabot_development_SES_PASS").with_value('secret') }
      # Exported Resource version - it { expect(exported_resources).to contain_ini_setting("cabot_development_SES_HOST").with_value('mail.example.com') }
      # Exported Resource version - it { expect(exported_resources).to contain_ini_setting("cabot_development_SES_PORT").with_value(25) }
      # Exported Resource version - it { expect(exported_resources).to contain_ini_setting("cabot_development_SES_USER").with_value('user') }
      # Exported Resource version - it { expect(exported_resources).to contain_ini_setting("cabot_development_SES_PASS").with_value('secret') }
    end    
  end
end
