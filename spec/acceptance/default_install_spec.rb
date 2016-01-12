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
      }     
    EOS
  }
  
  let(:config_manifest) {
    <<-EOS
      #{install_manifest}
    
      Class['::cabot'] -> 
      class { 'cabot::input::graphite':
        host => 'localhost',
        port => '80',
      }
    EOS
  }
  
  let(:alert_manifest) {
    <<-EOS    
    #{install_manifest}
    
    Class['::cabot'] ->
    class { 'cabot::output::hipchat':
      room    => 'myRoom',
      api_key => 'myKey',
    }
    EOS
  }
  
  context 'first install without plugins' do
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
    
    describe file('/opt/cabot_venv/conf/development.env') do
      its(:content) { should match /DATABASE_URL=postgres:\/\/cabot:cabot@localhost:5432\/cabot/ }
      its(:content) { should match /CELERY_BROKER_URL=redis:\/\/:cabotusesredisforocelery@localhost:6379\/1/ }
    end
  end
  
  context 'custom config added' do
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
    
    describe file('/opt/cabot_venv/conf/development.env') do
      its(:content) { should match /GRAPHITE_API=http:\/\/localhost:80\// }
      its(:content) { should match /GRAPHITE_FROM=-10min/ }
    end
  end
  
  context 'alert plugin added' do
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
  
    describe file('/opt/cabot_venv/conf/development.env') do
      its(:content) { should match /CABOT_PLUGINS_ENABLED=cabot_alert_hipchat/ }
      its(:content) { should match /HIPCHAT_ALERT_ROOM=myRoom/ }
      its(:content) { should match /HIPCHAT_API_KEY=myKey/ }
    end
  end
end

# TODO - Acceptance Testing - Buglist
# BUG (1): Logrotate on Puppet 4 (Future Parser)
  # rotate must be an integer => when rotate is an actual integer
  # FIX: set rotate as string
