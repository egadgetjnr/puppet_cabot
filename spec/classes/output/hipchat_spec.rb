require 'spec_helper'

describe 'cabot::output::hipchat' do
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
	  	  
    context "default" do                 
      let(:params) { {
        :room    => 'alertRoom',
        :api_key => 'myKey',
      } }

      it { should contain_ini_setting("cabot_development_HIPCHAT_URL").with_value('https://api.hipchat.com/v1/rooms/message') }
      it { should contain_ini_setting("cabot_development_HIPCHAT_ALERT_ROOM").with_value('alertRoom') }
      it { should contain_ini_setting("cabot_development_HIPCHAT_API_KEY").with_value('myKey') }
      # Exported Resource version - it { expect(exported_resources).to contain_ini_setting("cabot_development_HIPCHAT_URL").with_value('https://api.hipchat.com/v1/rooms/message') }
      # Exported Resource version - it { expect(exported_resources).to contain_ini_setting("cabot_development_HIPCHAT_ALERT_ROOM").with_value('alertRoom') }
      # Exported Resource version - it { expect(exported_resources).to contain_ini_setting("cabot_development_HIPCHAT_API_KEY").with_value('myKey') }
    end    
  end
end
