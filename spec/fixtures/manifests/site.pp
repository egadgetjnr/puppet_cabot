node 'default' {
  # Required
}

node 'host1' {
  class { '::cabot':
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
    admin_password   => 'password',
    admin_address    => 'cabot@example.com',
    environment      => 'development',
  }

  class { 'cabot::input::graphite':
    host => 'localhost',
    port => '80',
  }

  class { 'cabot::output::hipchat':
    room    => 'myRoom',
    api_key => 'myKey',
  }

  class { 'cabot::api':
    user     => 'root',
    password => 'password',
  }

  cabot_instance { 'test_instance_1':
    ensure         => present,
    users          => ['cabot'],
    alerts_enabled => true,
    status_checks  => [],
    alerts         => ['Hipchat'],
    address        => '127.0.0.1',
  }

  cabot_service { 'test_service_1':
    ensure         => present,
    users          => ['nicolas'],
    alerts_enabled => true,
    status_checks  => ['test_check_1'],
    alerts         => ['Hipchat'],
    url            => 'http://www.example.com',
    instances      => ['test_instance_1'],
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
}
