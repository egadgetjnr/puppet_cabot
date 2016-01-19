require 'spec_helper'

describe 'cabot::input::rota' do
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
	  
    context "ical" do    
      let(:params) { {
        :url => 'http://example.com/rota.ical',
      } }
            
      it { should contain_ini_setting("cabot_development_CALENDAR_ICAL_URL").with_value('http://example.com/rota.ical') }
      # Exported Resource version - it { expect(exported_resources).to contain_ini_setting("cabot_development_CALENDAR_ICAL_URL").with_value('http://example.com/rota.ical') }
    end    
  end
end
