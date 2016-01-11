require 'spec_helper'

describe 'cabot' do
  Puppet::Util::Log.level = :warning
  Puppet::Util::Log.newdestination(:console)
  
  let(:params) { {
    :install_postgres => true,
    :setup_db         => true,
    :install_gcc      => true,
    :install_git      => true,
    :install_ruby     => true,
    :install_python   => true,
    :install_nodejs   => true,
    :setup_logrotate  => true,
    :install_redis    => true,
    :install_apache   => true,
    :setup_apache     => true,   
  } }
  
  context "ubuntu" do
  	let(:facts) { {
	  	:osfamily 					      => 'Debian',
	  	:operatingsystem 			    => 'Ubuntu',
	  	:lsbdistid					      => 'Ubuntu',
	  	:lsbdistcodename 			    => 'precise',
	  	:operatingsystemrelease 	=> '12.04',
	  	:concat_basedir  			    => '/tmp', # Concat	 
	  } }
	  
	  context "ubuntu_defaults" do	  	    
		  it { should compile.with_all_deps }
	  
      it { should contain_class('cabot') }
      it { should contain_class('cabot::postgres') }
        it { should contain_class('postgresql::server') }
        it { should contain_postgresql__server__db('cabot') }
      it { should contain_class('cabot::install') }      
        it { should contain_class('gcc') }
        it { should contain_class('git') }
        it { should contain_class('ruby') }
        it { should contain_class('python') }
        it { should contain_class('nodejs') }
        #TODO it { should contain_package('postgresql') }
        it { should contain_package('foreman') }
        it { should contain_package('coffee-script') }
        it { should contain_package('less') }
        it { should contain_vcsrepo('/opt/cabot_source') }
        it { should contain_exec('Patch celeryconfig.py') }
        it { should contain_exec('cabot 0.0.1-dev bugfix1') }
      it { should contain_class('cabot::configure') }
        it { should contain_python__virtualenv('/opt/cabot_venv') }      
        it { should contain_file('/var/log/cabot') }
        it { should contain_logrotate__rule('cabot') }
        it { should contain_file('/opt/cabot_venv/conf') }      
          
        # Configuration (Collected with helpers/exported_resources.rb)
        it { expect(exported_resources).to contain_ini_setting("cabot_development_PORT").with_value('5000') }
        it { expect(exported_resources).to contain_ini_setting("cabot_development_DATABASE_URL").with_value('postgres://cabot:cabot@localhost:5432/cabot') }
        it { expect(exported_resources).to contain_ini_setting("cabot_development_CELERY_BROKER_URL").with_value('redis://:cabotusesredisforocelery@localhost:6379/1') }
        
        it { should contain_exec('cabot install') }
        it { should contain_exec('cabot syncdb') }
        it { should contain_exec('cabot migrate cabotapp') }
        it { should contain_exec('cabot migrate djcelery') }
        it { should contain_exec('cabot collectstatic') }
        it { should contain_exec('cabot compress') }
        it { should contain_exec('cabot init-script') }
        it { should contain_service('cabot') }
        
      it { should contain_class('cabot::redis') }
        it { should contain_class('redis') }
	    it { should contain_class('cabot::webserver') }
	      it { should contain_class('apache') }
	      it { should contain_apache__vhost('cabot') }
    end
    
#    context "ubuntu 2" do          
#      let(:params) { {
#        # different params 
#      } }
#      
#      it { should compile.with_all_deps }
#    
#      TODO
#    end
  end
  
  context "centos" do
  	let(:facts) { {
	    :osfamily 				           => 'RedHat',
	  	:operatingsystem 		         => 'CentOS',
	  	:operatingsystemrelease      => '6.0',
	  	:lsbmajdistrelease           => '6',
	  	:operatingsystemmajrelease   => '6',
	  	:concat_basedir  		         => '/tmp',
	  	:clientcert				           => 'centos',	# HIERA !!!
      :kernel                      => 'Linux',
	  } }
	  
  	it { should compile.with_all_deps }
  
    it { should contain_class('cabot') }
    it { should contain_class('cabot::postgres') }
      it { should contain_class('postgresql::server') }
      it { should contain_postgresql__server__db('cabot') }
    it { should contain_class('cabot::install') }      
      it { should contain_class('gcc') }
      it { should contain_class('git') }
      it { should contain_class('ruby') }
      it { should contain_class('python') }
      it { should contain_class('nodejs') }
      #TODO it { should contain_package('postgresql') }
      it { should contain_package('foreman') }
      it { should contain_package('coffee-script') }
      it { should contain_package('less') }
      it { should contain_vcsrepo('/opt/cabot_source') }
      it { should contain_exec('Patch celeryconfig.py') }
      it { should contain_exec('cabot 0.0.1-dev bugfix1') }
    it { should contain_class('cabot::configure') }
      it { should contain_python__virtualenv('/opt/cabot_venv') }      
      it { should contain_file('/var/log/cabot') }
      it { should contain_logrotate__rule('cabot') }
      it { should contain_file('/opt/cabot_venv/conf') }      
        
      # Configuration (Collected with helpers/exported_resources.rb)
      it { expect(exported_resources).to contain_ini_setting("cabot_development_PORT").with_value('5000') }
      it { expect(exported_resources).to contain_ini_setting("cabot_development_DATABASE_URL").with_value('postgres://cabot:cabot@localhost:5432/cabot') }
      it { expect(exported_resources).to contain_ini_setting("cabot_development_CELERY_BROKER_URL").with_value('redis://:cabotusesredisforocelery@localhost:6379/1') }
      
      it { should contain_exec('cabot install') }
      it { should contain_exec('cabot syncdb') }
      it { should contain_exec('cabot migrate cabotapp') }
      it { should contain_exec('cabot migrate djcelery') }
      it { should contain_exec('cabot collectstatic') }
      it { should contain_exec('cabot compress') }
      it { should contain_exec('cabot init-script') }
      it { should contain_service('cabot') }
      
    it { should contain_class('cabot::redis') }
      it { should contain_class('redis') }
    it { should contain_class('cabot::webserver') }
      it { should contain_class('apache') }
      it { should contain_apache__vhost('cabot') }
  end  
end
