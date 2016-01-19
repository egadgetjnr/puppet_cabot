require 'spec_helper_acceptance'

describe 'cabot class' do  
  let(:install_manifest) {
    <<-EOS
      class { '::cabot': 
        install_postgres => true,
        setup_db         => true,
        install_gcc      => true,
        install_git      => true,
        install_ruby     => true,
        install_python   => true,
        install_nodejs   => true,
        setup_logrotate  => false,    # BUG (1)
        install_redis    => true,
        install_apache   => true,
        setup_apache     => true,  
        admin_password   => 'password',
        admin_address    => 'cabot@example.com',
      }     
    EOS
  }
  
  let(:config_section) {
    <<-EOS    
      class { 'cabot::input::graphite':
        host => 'localhost',
        port => '80',
      }
    EOS
  }
  
  let(:config_manifest) {
    <<-EOS
      #{install_manifest}    
      #{config_section}
    EOS
  }
  
  let(:alert_section) {
    <<-EOS    
    class { 'cabot::output::hipchat':
      room    => 'myRoom',
      api_key => 'myKey',
    }
    
    cabot::alert_plugin { 'sensu':
      url     => 'git+https://github.com/Lavaburn/cabot-alert-sensu.git',
      version => '1.2.8',
      config  => {
        'SENSU_PORT'  => {'value' => '3030'},
        'SENSU_HOST'  => {'value' => 'localhost'},
        'SENSU_DEBUG' => {'value' => 'False'},
      },
    }
    EOS
  }
  
  let(:alert_manifest) {
    <<-EOS    
    #{install_manifest}
    #{alert_section}
    EOS
  }
  
  let(:complete_manifest) {
    <<-EOS    
    #{alert_section}
    #{config_section}
    #{install_manifest}    
    EOS
  }
  
  let(:api_setup_manifest) {
    <<-EOS
    class { 'cabot::api': 
      user     => 'cabot',
      password => 'password',
      users    => {
        1 => 'cabot',
      }
    }
    EOS
  }
  
  let (:api_manifest1) {
    <<-EOS
    cabot_instance { 'test_instance_1':
      ensure         => present,
      users          => ['cabot'],
      alerts_enabled => true,
      status_checks  => [],
      alerts         => ['Hipchat'],
      address        => '127.0.0.1',
    }    
    
    cabot_graphite_check { 'test_check_1':
      ensure               => present,
      active               => true,
      importance           => 'WARNING',
      frequency            => 1,
      debounce             => 0,
      metric               => 'sys.collectd.network.*.twr1.extrem*.snmp.temperature',
      check_type           => '>',
      value                => '32',
      expected_num_hosts   => 1,
      expected_num_metrics => 0,
    }
    
    cabot_service { 'test_service_1':
      ensure         => present,
      users          => ['cabot'],
      alerts_enabled => true,
      status_checks  => ['test_check_1'],
      alerts         => ['Hipchat'],
      url            => 'http://www.example.com',
      instances      => ['test_instance_1'],
    }
    
    Cabot_instance['test_instance_1'] -> Cabot_service['test_service_1']
    Cabot_graphite_check['test_check_1'] -> Cabot_service['test_service_1']
    EOS
  }
  
  let (:api_manifest2) {
    <<-EOS
    cabot_service { 'test_service_1':
      alerts_enabled => false,
    }
    EOS
  }
  
  let (:api_manifest3) {
    <<-EOS
    cabot_service { 'test_service_1':
      users => ['non_existing'],
    }
    EOS
  }
        
  context 'first install without plugins' do
#    before { skip("Not testing this today") }

    it 'should install without errors and be idempotent' do
  
      # Run without errors
      apply_manifest(install_manifest, :catch_failures => true)
      
      # Idempotency - no further changes..
      result = apply_manifest(install_manifest, :catch_failures => true)
      expect(result.exit_code).to be_zero
    end  
  
    describe port(80) do
      it { should be_listening }
    end
    
    describe port(5000) do
      it { should be_listening }
    end
  
    describe service('cabot') do
      it { should be_running }
    end
    
    describe file('/opt/cabot_venv/conf/production.env') do
      its(:content) { should match /DATABASE_URL=postgres:\/\/cabot:cabot@localhost:5432\/cabot/ }
      its(:content) { should match /CELERY_BROKER_URL=redis:\/\/:cabotusesredisforocelery@localhost:6379\/1/ }
      its(:content) { should match /CABOT_PLUGINS_ENABLED=cabot_alert_email,cabot_alert_hipchat,cabot_alert_twilio/ }
    end
  end
  
  context 'custom config added' do
#    before { skip("Not testing this today") }

    it 'should update config when adding custom config' do
      # Run without errors
      apply_manifest(config_manifest, :catch_failures => true)
      
      # Idempotency - no further changes..
      result = apply_manifest(config_manifest, :catch_failures => true)
      expect(result.exit_code).to be_zero
    end
    
    describe service('cabot') do
      it { should be_running }
    end
    
    describe file('/opt/cabot_venv/conf/production.env') do
      its(:content) { should match /GRAPHITE_API=http:\/\/localhost:80\// }
      its(:content) { should match /GRAPHITE_FROM=-10min/ }
    end
  end
  
  context 'alert plugin added' do
#    before { skip("Not testing this today") }

    it 'should update config when adding alert plugin' do
      # Run without errors
      apply_manifest(alert_manifest, :catch_failures => true)
      
      # Idempotency - no further changes..
      result = apply_manifest(alert_manifest, :catch_failures => true)
      expect(result.exit_code).to be_zero
    end

    describe service('cabot') do
      it { should be_running }
    end
  
    describe file('/opt/cabot_venv/conf/production.env') do
      its(:content) { should match /CABOT_PLUGINS_ENABLED=cabot_alert_email,cabot_alert_hipchat,cabot_alert_twilio,cabot_alert_sensu==1.2.8/ }
      its(:content) { should match /HIPCHAT_ALERT_ROOM=myRoom/ }
      its(:content) { should match /HIPCHAT_API_KEY=myKey/ }
      its(:content) { should match /SENSU_PORT=3030/ }
    end
  end

  context 'clean up and run full integrated manifest' do
#    before { skip("Not testing this today") }

    it 'should clean up' do
      shell('service cabot stop; sleep 30')
      shell("rm -rf /opt/cabot_source")
      shell("rm -rf /opt/cabot_venv")
      shell('su postgres -c "dropdb cabot"')
    end
  
    it 'should run full integrated manifest' do
      # Run without errors
      apply_manifest(complete_manifest, :catch_failures => true)
      
      # Idempotency - no further changes..
      result = apply_manifest(complete_manifest, :catch_failures => true)
      expect(result.exit_code).to be_zero
    end
    
    describe port(80) do
      it { should be_listening }
    end
    
    describe port(5000) do
      it { should be_listening }
    end
    
    describe service('cabot') do
      it { should be_running }
    end
  
    describe file('/opt/cabot_venv/conf/production.env') do
      its(:content) { should match /DATABASE_URL=postgres:\/\/cabot:cabot@localhost:5432\/cabot/ }
      its(:content) { should match /CELERY_BROKER_URL=redis:\/\/:cabotusesredisforocelery@localhost:6379\/1/ }
      its(:content) { should match /GRAPHITE_API=http:\/\/localhost:80\// }
      its(:content) { should match /GRAPHITE_FROM=-10min/ }      
      its(:content) { should match /CABOT_PLUGINS_ENABLED=cabot_alert_email,cabot_alert_hipchat,cabot_alert_twilio,cabot_alert_sensu==1.2.8/ }
      its(:content) { should match /HIPCHAT_ALERT_ROOM=myRoom/ }
      its(:content) { should match /HIPCHAT_API_KEY=myKey/ }
      its(:content) { should match /SENSU_PORT=3030/ }
    end
  end  
  
  context 'setup and run custom types/providers' do
#    before { skip("Not testing this today") }

    it 'should setup api manifest' do
      # Run without errors
      apply_manifest(api_setup_manifest, :catch_failures => true)
      
      # Idempotency - no further changes..
      result = apply_manifest(api_setup_manifest, :catch_failures => true)
      expect(result.exit_code).to be_zero
    end    
    
    it 'should run api-1 manifest' do
      # Run without errors
      apply_manifest(api_manifest1, :catch_failures => true)
      
      # Idempotency - no further changes..
      result = apply_manifest(api_manifest1, :catch_failures => true)
      expect(result.exit_code).to be_zero
    end 
       
    it 'should run api-2 manifest' do
      # Run without errors
      result = apply_manifest(api_manifest2, :catch_failures => true)
      expect(result.exit_code).not_to eq(0)
            
      # Idempotency - no further changes..
      result = apply_manifest(api_manifest2, :catch_failures => true)
      expect(result.exit_code).to be_zero
    end  
   
    it 'should alert on api-3 manifest' do
      # Run with errors
      result = apply_manifest(api_manifest3, :catch_failures => false)
      expect(result.stderr).to match /.*Users Hash does not contain.*/      
    end
  end
end

# TODO - Acceptance Testing - BUG (1): Logrotate on Puppet 4 (Future Parser)
  # rotate must be an integer => when rotate is an actual integer
  # FIX: set rotate as string
