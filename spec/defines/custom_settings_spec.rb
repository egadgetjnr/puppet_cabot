require 'spec_helper'

describe 'cabot::custom_settings', :type => :define do
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
    }"
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
            
      it { expect(exported_resources).to contain_ini_setting("cabot_development_CALENDAR_ICAL_URL").with_value('http://example.com/rota.ical') }
    end      
  end   
end
