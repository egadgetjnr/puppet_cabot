require 'spec_helper'

describe 'cabot' do
  Puppet::Util::Log.level = :warning
  Puppet::Util::Log.newdestination(:console)
  
#  let(:pre_condition) { 
#    "class { '::a': }" 
#  }

  context "ubuntu" do
  	let(:facts) { {
	  	:osfamily 					      => 'debian',
	  	:operatingsystem 			    => 'Ubuntu',
#	  	:lsbdistid					      => 'Ubuntu',
#	  	:lsbdistcodename 			    => 'precise',
#	  	:operatingsystemrelease 	=> '12.04',
#	  	:concat_basedir  			    => '/tmp', # Concat	  	
	  } }
	  
#    let(:params) { {
#      :compile_microkernel  => false,    
#    } }
	  
	  context "ubuntu_defaults" do	  
		  it { should compile.with_all_deps }
	  
      it { should contain_class('cabot') }
        
#      TODO
    end
  end
  
  context "centos_defaults" do
  	let(:facts) { {
	    :osfamily 				           => 'redhat',
	  	:operatingsystem 		         => 'CentOS',
#	  	:operatingsystemrelease      => '6.0',
#	  	:lsbmajdistrelease           => '6',
#	  	:operatingsystemmajrelease   => '6',
#	  	:concat_basedir  		         => '/tmp',
#	  	:clientcert				           => 'centos',	# HIERA !!!
	  } }
	  
    let(:params) { {     
      #:enable_tftp           => false,
    } }
    
  	it { should compile.with_all_deps }
    
    it { should contain_class('cabot') }
              
    # TODO        
  end  
end
