require 'spec_helper'

describe 'cabot::custom_settings', :type => :define do
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
	  
    #  describe "???" do
	  context "default" do	  	        
      let(:title) {
        'rota'
      }
      
      let(:params) { {
        :config  => {
          'CALENDAR_ICAL_URL' => {'value' => 'http://example.com/rota.ical'},
        },
      } }
      
      it { should contain_cabot__setting('CALENDAR_ICAL_URL') }
      
      it { should contain_ini_setting("cabot_development_CALENDAR_ICAL_URL").with_value('http://example.com/rota.ical') }
      # Exported Resource version - it { expect(exported_resources).to contain_ini_setting("cabot_development_CALENDAR_ICAL_URL").with_value('http://example.com/rota.ical') }
    end      
  end   
end
