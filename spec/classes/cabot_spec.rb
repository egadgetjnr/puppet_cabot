require 'spec_helper'

describe 'cabot' do
  Puppet::Util::Log.level = :warning
  Puppet::Util::Log.newdestination(:console)
  
  let(:params) { {
    :install_apache => true, 
    :install_postgres => true,   
  } }
  
  context "ubuntu" do
  	let(:facts) { {
	  	:osfamily 					      => 'debian',
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
	    it { should contain_postgresql__server__db('cabot') }
      it { should contain_class('cabot::install') }        
      it { should contain_vcsrepo('/opt/cabot_source') }
      it { should contain_exec('Patch celeryconfig.py') }
      it { should contain_class('cabot::configure') }
      it { should contain_python__virtualenv('/opt/cabot_venv') }        
      it { should contain_file('/opt/cabot_venv/conf/development.env') }
      it { should contain_exec('cabot install') }
      it { should contain_exec('cabot syncdb') }
      it { should contain_exec('cabot migrate cabotapp') }
      it { should contain_exec('cabot migrate djcelery') }
      it { should contain_exec('cabot collectstatic') }
      it { should contain_exec('cabot compress') }
      it { should contain_exec('cabot init-script') }
      it { should contain_service('cabot') }
      it { should contain_class('cabot::redis') }   
	    it { should contain_class('cabot::webserver') }
    end
    
#    context "ubuntu_package" do          
#      let(:params) { {
#        :package          => "package.deb",  
#        :setup_logrotate  => true,      
#      } }
#          
#      
#      it { should compile.with_all_deps }
#    
#      it { should contain_class('cabot') }
#    end
  end
  
  context "centos_defaults" do
  	let(:facts) { {
	    :osfamily 				           => 'redhat',
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
  
    it { should contain_class('cabot') }
    it { should contain_class('cabot::postgres') }
    it { should contain_postgresql__server__db('cabot') }
    it { should contain_class('cabot::install') }        
    it { should contain_vcsrepo('/opt/cabot_source') }
    it { should contain_exec('Patch celeryconfig.py') }
    it { should contain_class('cabot::configure') }
    it { should contain_python__virtualenv('/opt/cabot_venv') }        
    it { should contain_file('/opt/cabot_venv/conf/development.env') }
    it { should contain_exec('cabot install') }
    it { should contain_exec('cabot syncdb') }
    it { should contain_exec('cabot migrate cabotapp') }
    it { should contain_exec('cabot migrate djcelery') }
    it { should contain_exec('cabot collectstatic') }
    it { should contain_exec('cabot compress') }
    it { should contain_exec('cabot init-script') }
    it { should contain_service('cabot') }
    it { should contain_class('cabot::redis') }   
    it { should contain_class('cabot::webserver') }
  end  
end
