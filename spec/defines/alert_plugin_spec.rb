require 'spec_helper'

describe 'cabot::alert_plugin', :type => :define do
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
	  context "config_only" do	  	        
      let(:title) {
        'email'
      }
      
      let(:params) { {
        :config  => {
          'SES_HOST' => {'value' => 'mail.example.com'},
          'SES_PORT' => {'value' => 25},
          'SES_USER' => {'value' => 'user', 'ensure' => 'present'},
          'SES_PASS' => {'value' => 'secret', 'ensure' => 'present'},
        },
      } }
      
      it { should contain_cabot__alert_plugin('email') }
      
      it { should_not contain_python__pip('cabot-alert-email') }
          
      it { should contain_cabot__setting('SES_HOST') }
      it { should contain_cabot__setting('SES_PORT') }
      it { should contain_cabot__setting('SES_USER') }
      it { should contain_cabot__setting('SES_PASS') }
            
      it { should contain_ini_setting("cabot_development_SES_HOST").with_value('mail.example.com') }
      it { should contain_ini_setting("cabot_development_SES_PORT").with_value(25) }
      it { should contain_ini_setting("cabot_development_SES_USER").with_value('user') }
      it { should contain_ini_setting("cabot_development_SES_PASS").with_value('secret') }              
      # Exported Resource version - it { expect(exported_resources).to contain_ini_setting("cabot_development_SES_HOST").with_value('mail.example.com') }
      # Exported Resource version - it { expect(exported_resources).to contain_ini_setting("cabot_development_SES_PORT").with_value(25) }
      # Exported Resource version - it { expect(exported_resources).to contain_ini_setting("cabot_development_SES_USER").with_value('user') }
      # Exported Resource version - it { expect(exported_resources).to contain_ini_setting("cabot_development_SES_PASS").with_value('secret') }
    end    
    
    context "plugin" do              
      let(:title) {
        'sensu'
      }
      
      let(:params) { {
        :url     => 'git+https://github.com/Lavaburn/cabot-alert-sensu.git',
        :version => 'present',
        :config  => {
          'SENSU_PORT'  => {'value' => '3030'},
          'SENSU_HOST'  => {'value' => 'localhost'},
          'SENSU_DEBUG' => {'value' => 'False'},
        },    
      } }

      it { should contain_cabot__alert_plugin('sensu') }
      
      it { should contain_python__pip('cabot-alert-sensu').with(
        'ensure'     => 'present',
        'url'        => 'git+https://github.com/Lavaburn/cabot-alert-sensu.git',
        'virtualenv' => '/opt/cabot_venv'
      ) }
          
      it { should contain_cabot__setting('SENSU_PORT') }
      it { should contain_cabot__setting('SENSU_HOST') }
      it { should contain_cabot__setting('SENSU_DEBUG') }
            
      it { should contain_ini_setting("cabot_development_SENSU_PORT").with_value('3030') }
      it { should contain_ini_setting("cabot_development_SENSU_HOST").with_value('localhost') }
      it { should contain_ini_setting("cabot_development_SENSU_DEBUG").with_value('False') }                
      # Exported Resource version - it { expect(exported_resources).to contain_ini_setting("cabot_development_SENSU_PORT").with_value('3030') }
      # Exported Resource version - it { expect(exported_resources).to contain_ini_setting("cabot_development_SENSU_HOST").with_value('localhost') }
      # Exported Resource version - it { expect(exported_resources).to contain_ini_setting("cabot_development_SENSU_DEBUG").with_value('False') }   
    end    
  end   
end
