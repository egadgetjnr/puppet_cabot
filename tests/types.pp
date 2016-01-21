# Custom Type: Cabot - Instance
#cabot_instance { 'test2':
#  ensure         => present,
#  users          => ['root2', 'nicolas'],
#  alerts_enabled => true,
#  status_checks  => [],
#  alerts         => ['Hipchat', 'Email'],
#  address        => '172.19.51.12',
#}

# Custom Type: Cabot - Graphite Check
#cabot_service { 'srv_test1':
#  ensure         => present,
#  users          => ['nicolas'],
#  alerts_enabled => true,
#  status_checks  => ['test_check1'],
#  alerts         => ['Hipchat', 'Email'],
#  url            => 'http://www.rcswimax.com',
#  instances      => ['test2'],
#}

# Custom Type: Cabot - Graphite Check
#cabot_graphite_check { 'test_check1':
#  ensure               => present,
#  active               => true,
#  importance           => 'WARNING',
#  frequency            => 1,
#  debounce             => 0,
#  metric               => 'sys.collectd.network.*.twr1.extrem*.snmp.temperature',
#  check_type           => '>',
#  value                => '32',
#  expected_num_hosts   => 2,
#  expected_num_metrics => 0,
#}
