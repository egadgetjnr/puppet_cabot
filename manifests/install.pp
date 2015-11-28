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
    }

  # Other Packages
    # Distro  
  package { 'postgresql':
    ensure => 'installed',
  }
  ->
  package { 'python-psycopg2':
    ensure => 'installed',
  }
  ->
  package { ['libpq-dev', 'libldap2-dev', 'libsasl2-dev']:
    ensure => 'installed',
  }
  
  # TODO BUGFIX ??? less@1.3
  package { 'less':
    ensure => 'installed',# NPM package ??
  }
  
    # Gems
  package { 'foreman':
    provider => 'gem',
  }

    # NPM (http://registry.npmjs.org)
  package { 'coffee-script':
    ensure   => 'present',
    provider => 'npm',
  }
  

  # Get Source Code
  # puppetlabs/vcsrepo
  vcsrepo { $source_dir:
    ensure   => $source_ensure,
    provider => git,
    source   => $git_url,
    revision => $source_version,
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
