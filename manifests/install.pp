# Class: cabot::install
#
# Private class. Only calling cabot main class is supported.
#
class cabot::install {
  # Dependencies
  # puppetlabs/gcc
  if ($cabot::install_gcc) {
    include ::gcc
  }

  # puppetlabs/git
  if ($cabot::install_git) {
    include ::git
  }

  # puppetlabs/ruby
  if ($cabot::install_ruby) {
    include ::ruby
  }

  # stankevich/python (>= 1.9.8)
  if ($cabot::install_python) {
    class { '::python':
      pip        => 'present',
      dev        => 'present',
      virtualenv => 'present',
    # gunicorn   => false,
    }
  }

  # puppetlabs/nodejs
  if ($cabot::install_nodejs) {
    include ::nodejs
  }

  # Distro Packages
  if ($cabot::install_dependencies) {
    if $::osfamily == 'Debian' {
      package { [
        'libpq-dev',
        'libldap2-dev',
        'libsasl2-dev']:
        ensure => 'installed',
      }
    } else {
      fail("Unsupported operating system family: ${::osfamily}. No dependency packages defined for this OS.")
    }
  }

  # (Ruby) Gem Packages
  if ($cabot::install_gem_packages) {
    package { 'foreman':
      ensure   => 'installed',
      provider => 'gem',
    }
  }

  # (NodeJS) NPM Packages
  # http://registry.npmjs.org
  if ($cabot::install_npm_packages) {
    ensure_packages(['coffee-script', 'less'], {
      ensure   => 'installed',
      provider => 'npm',
      require => Class['::nodejs'],
    })
  }

  # Get Source Code
  # puppetlabs/vcsrepo
  vcsrepo { $cabot::source_dir:
    ensure   => 'present',
    source   => $cabot::source_url,
    revision => $cabot::source_revision,
    provider => 'git',
  }

  # Source Code Patch 1 - Allow custom param for cleaning up the history
  $patch1 = "${cabot::source_dir}/celeryconfig.patch"
  Vcsrepo[$cabot::source_dir] ->
  file { $patch1:
    ensure => 'present',
    source => 'puppet:///modules/cabot/celeryconfig.patch',
  }

  File[$patch1] ~>
  exec { 'Patch celeryconfig.py':
    command     => "/usr/bin/patch -p0 < ${patch1}",
    cwd         => $cabot::source_dir,
    refreshonly => true,
  }

  # Bugfix 1 [Cabot 0.0.1-dev]
  Vcsrepo[$cabot::source_dir] ~>
  exec { 'cabot 0.0.1-dev bugfix1':
    cwd         => $cabot::source_dir,
    command     => "/bin/sed -i '/distribute==/d' ${cabot::source_dir}/setup.py",
    refreshonly => true,
  }
}
