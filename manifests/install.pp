# Class: cabot::install
#
# Private class. Only calling cabot main class is supported.
#
class cabot::install inherits ::cabot {
  # Dependencies
    # puppetlabs/gcc
    # TODO if ()
    include ::gcc

    # puppetlabs/git
    # TODO if ()
    include ::git

    # puppetlabs/ruby
    # TODO if ()
    include ::ruby

    # stankevich/python
    # TODO if ()
    class { 'python' :
      pip        => true,
      dev        => true,
      virtualenv => true,
      gunicorn   => true,
    }

    # puppetlabs/nodejs
    # TODO if ()
    include ::nodejs

    # BUG in 0.7.1 on Ubuntu 14.04 ??
    package { 'npm':
      ensure  => present,
      name    => 'npm',
      require => Anchor['nodejs::repo']
    }

  # Other Packages
  package { 'foreman':
    provider => 'gem',
  }

  Package['npm']
  ->
  package { ['coffee-script', 'less@1.3']:
    ensure   => 'present',
    provider => 'npm',
  } # http://registry.npmjs.org/


  # Get Source Code
  $source_dir = '/opt/cabot_source'  # TODO

  # puppetlabs/vcsrepo
  vcsrepo { $source_dir:
    ensure   => present,
    provider => git,
    source   => 'https://github.com/arachnys/cabot.git',
  }
}
