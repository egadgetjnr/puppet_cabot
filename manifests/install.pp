# Class: cabot::install
#
# Private class. Only calling cabot main class is supported.
#
class cabot::install inherits ::cabot {
  # Dependencies
    # puppetlabs/gcc
    if ($install_gcc) {
      include ::gcc
    }

    # puppetlabs/git
    if ($install_git) {
      include ::git
    }

    # puppetlabs/ruby
    if ($install_ruby) {
      include ::ruby
    }

    # stankevich/python
    if ($install_python) {
	    class { '::python' :
	      pip        => true,
	      dev        => true,
	      virtualenv => true,
	      #gunicorn   => false,
	    }
	  }

    # puppetlabs/nodejs
    if ($install_nodejs) {
      include ::nodejs

      #TODO add to nodejs profile
      # BUG in 0.7.1 on Ubuntu 12.04 ??
      # NOT REQUIRED on Ubuntu 14.04 !!!
#    package { 'npm':
#      ensure  => present,
#      require => Anchor['nodejs::repo']
#    }
    }

  # Other Packages
  package { 'foreman':
    provider => 'gem',
  }

  #Package['npm'] ->   # NOT REQUIRED on Ubuntu 14.04 !!!
  package { ['coffee-script', 'less']:  # TODO 'less@1.3'
    ensure   => 'present',
    provider => 'npm',
  } # http://registry.npmjs.org/

  # TODO !!!
  #  package { 'postgresql':
  #    ensure => 'installed',
  #  }
  #  ->
  #  package { 'python-psycopg2':
  #    ensure => 'installed',
  #  }
  #  ->
  #  package { ['libpq-dev', 'libldap2-dev', 'libsasl2-dev']:
  #    ensure => 'installed',
  #  }

  # Get Source Code
  # puppetlabs/vcsrepo
  vcsrepo { $source_dir:
    ensure   => present,  # TODO pin/update !! PARAM!
    provider => git,
    source   => $git_url,
  }
  ->
  # Patching code to allow custom param for cleaning up the history
  file { "${source_dir}/celeryconfig.patch":
    ensure  => present,
    source  => 'puppet:///modules/cabot/celeryconfig.patch',
  }

  exec { 'Patch celeryconfig.py':
    command     => "/usr/bin/patch -p0 < ${source_dir}/celeryconfig.patch",
    cwd         => $source_dir,
    require     => File["${source_dir}/celeryconfig.patch"],
    subscribe   => Vcsrepo[$source_dir],
    refreshonly => true,
  }
}
