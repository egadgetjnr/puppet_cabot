# Puppet Module for Arachnys Cabot
===========================================

[![Build Status](https://travis-ci.org/Lavaburn/puppet_cabot.png)](https://travis-ci.org/Lavaburn/puppet_cabot)
[![Coverage Status](https://coveralls.io/repos/github/Lavaburn/puppet_cabot/badge.svg?branch=v2)](https://coveralls.io/github/Lavaburn/puppet_cabot?branch=v2)
[![Puppet Forge](http://img.shields.io/puppetforge/v/Lavaburn/cabot.svg)](https://forge.puppetlabs.com/Lavaburn/cabot)

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
* yo61/logrotate

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

## Supported Environments

* Ruby 1.9.3 - Supported
* Ruby 2.1.8 - Supported
* Ruby 2.2.4 - Supported on Puppet 4

* Puppet 3.7.5 - Supported (on Ruby <= 2.2)
* Puppet 3.8.5 - Not Supported (Strange rspec errors)
* Puppet 4.2.3 - Supported
* Puppet 4.3.1 - Supported

Acceptance tested on:
* Ubuntu 14.04

## Testing

### Set up for testing
```
gem install bundler
bundle install
```

To choose a different Puppet version, use PUPPET_VERSION environmental variable
```
PUPPET_VERSION="4.2.3" bundle install
```

### Syntax and Spec Testing
```
bundle exec rake test
```

### Acceptance testing with Beaker
```
bundle exec rake beaker
```
You can use the environmental variables BEAKER_debug, BEAKER_destroy and BEAKER_provision 
