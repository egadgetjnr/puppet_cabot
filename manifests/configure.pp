# Class: cabot::configure
#
# Private class. Only calling cabot main class is supported.
#
class cabot::configure inherits ::cabot {
  # TODO PARAMS
  $source_dir = '/opt/cabot_source'
  $env_dir = '/opt/cabot_venv'
  $ENV = 'development'
  $foreman = '/usr/local/bin/foreman'

  # Local Parameters (shorthands)
  $foreman_run = "${foreman} run -e conf/${ENV}.env"

  # Create Python VirtualEnv
  python::virtualenv { $env_dir :
    ensure       => present,
    #owner        => 'appuser',
    #group        => 'apps',
  }

  # BUGFIX FOR SETUPTOOLS 15.1 wget https://bootstrap.pypa.io/ez_setup.py -O - | python


  file { "${env_dir}/conf":
    ensure  => 'directory',
    require => Python::Virtualenv[$env_dir]
  }

  file { "${env_dir}/conf/${ENV}.env":
    ensure  => 'file',
    content => template('cabot/environment.env.erb'),
    require => File["${env_dir}/conf"]
  }

  exec { 'cabot install':
    command     => "${foreman_run} ${env_dir}/bin/pip install --timeout=30 --editable ${source_dir} --exists-action=w",
    cwd         => $env_dir,
    subscribe   => File["${env_dir}/conf/${ENV}.env"],
    refreshonly => true,
  }

  exec { 'cabot syncdb':
    command     => "${foreman_run} python manage.py syncdb",
    cwd         => $env_dir,
    subscribe   => Exec['cabot install'],
    refreshonly => true,
  }

  exec { 'cabot migrate cabotapp':
    command     => "${foreman_run} python manage.py migrate cabotapp --noinput",
    cwd         => $env_dir,
    subscribe   => Exec['cabot syncdb'],
    refreshonly => true,
  }

  exec { 'cabot migrate djcelery':
    command     => "${foreman_run} python manage.py migrate djcelery --noinput",
    cwd         => $env_dir,
    subscribe   => Exec['cabot migrate cabotapp'],
    refreshonly => true,
  }

#DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#export PATH=$PATH:$DIR/../bin:$DIR/../app
#export PYTHONPATH=$PYTHONPATH:$DIR/../app

  exec { 'cabot collectstatic':
    command     => "${foreman_run} python manage.py collectstatic --noinput",
    cwd         => $env_dir,
    subscribe   => Exec['cabot migrate djcelery'],
    refreshonly => true,
  }

  exec { 'cabot compress':
    command     => "${foreman_run} compress",
    cwd         => $env_dir,
    subscribe   => Exec['cabot collectstatic'],
    refreshonly => true,
  }

  $procfile = "${source_dir}/Procfile"
  $env_file = "${source_dir}/conf/${ENV}.env"
  $template = "${source_dir}/upstart"
  $user = 'root'  # TODO .?.

  exec { 'cabot init-script':
    command     => "${foreman} export upstart /etc/init -f ${procfile} -e ${env_file} -u ${user} -a cabot -t ${template}",
    cwd         => $env_dir,
    subscribe   => Exec['cabot compress'],
    refreshonly => true,
  }

  #TODO Service ?
}
