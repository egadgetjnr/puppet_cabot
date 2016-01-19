# Puppet Module for Arachnys Cabot
==================================

## Overview 
This module installs and sets up Cabot for first use 

## Dependencies
* puppetlabs/vcsrepo
* stankevich/python
* puppetlabs/inifile
* puppetlabs/stdlib

Optional:
* puppetlabs/postgresql
* puppetlabs/gcc  
* puppetlabs/git
* puppetlabs/ruby
* puppetlabs/nodejs
* thomasvandoren/redis
* puppetlabs/apache  

## Installation
1. Full setup (all local, nothing else needed) [requires all dependency modules] 
```
class { 'cabot': 
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
  admin_password   => 'password',			# Required. Recommended usage: Hiera-ENC
  admin_address    => 'cabot@example.com',	# Required
}
```

## Configuration

1. Enable Graphite Inputs
```
cabot::custom_settings { 'graphite':
  config  => {
    'GRAPHITE_API'  => {'value' => "http://HOST:PORT/"},
    'GRAPHITE_USER' => {'value' => 'USER'},
    'GRAPHITE_PASS' => {'value' => 'PASS'},
    'GRAPHITE_FROM' => {'value' => '-10minute'},# Default
  },
}
```

2. Enable E-Mail Output
```
cabot::alert_plugin { 'email':
  url => 'GIT_URL',
  config  => {
    'SES_HOST' => {'value' => 'HOST'},
    'SES_PORT' => {'value' => '25'},
    'SES_USER' => {'value' => 'USER'},
    'SES_PASS' => {'value' => 'PASS'},
  },
}
```

3. Add custom alert plugin
```
cabot::alert_plugin { 'NAME':
  url => 'GIT_URL',
  config  => {
    'PARAM1' => {'value' => 'VALUE1'},
  },
}
```