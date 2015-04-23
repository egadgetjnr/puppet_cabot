# Class: cabot::configure
#
# Private class. Only calling cabot main class is supported.
#
class cabot::configure inherits ::cabot {
  # Local Parameters (shorthands)
  $ENV = $environment
  $foreman_run = "${foreman} run -e ${env_dir}/conf/${ENV}.env"
  $source_activate = "source ${env_dir}/bin/activate"


  # Create Python VirtualEnv
  python::virtualenv { $env_dir :
    ensure       => present,
    #owner        => 'appuser',
    #group        => 'apps',
  }


  # Bugfixes for Cabot 0.0.1-dev
  exec { 'cabot 0.0.1-dev bugfix1':
    command     => "/bin/sed -i '/distribute==/d' ${source_dir}/setup.py",
    cwd         => $source_dir,
    subscribe   => Python::Virtualenv[$env_dir],
    refreshonly => true,
  } -> Exec['cabot install']


  # Setup Log Dir
  file { $log_dir:
    ensure  => 'directory',
  }


  # Setup Configuration
  file { "${env_dir}/conf":
    ensure  => 'directory',
    require => Python::Virtualenv[$env_dir]
  }

  # Configuration TEMPLATE
  $config_env_dir       = $env_dir
  $config_port          = $port
  $config_timezone      = $timezone
  $config_admin_address = $admin_address
  $config_django_secret = $django_secret

  $config_db_username = $db_username
  $config_db_password = $db_password
  $config_db_hostname = $db_hostname
  $config_db_port     = $db_port
  $config_db_database = $db_database

  $config_redis_hostname = $redis_hostname
  $config_redis_port     = $redis_port
  $config_redis_database = $redis_database

  $config_graphite_host     = "http://${graphiteweb_host}:${graphiteweb_port}/"
  $config_graphite_username = $graphite_username
  $config_graphite_password = $graphite_password

  file { "${env_dir}/conf/${ENV}.env":
    ensure  => 'file',
    content => template('cabot/environment.env.erb'),
    require => File["${env_dir}/conf"]
  }


  # Installation
  exec { 'cabot install':
    command     => "${foreman_run} ${env_dir}/bin/pip install --timeout=30 --editable ${source_dir} --exists-action=w",
    cwd         => $env_dir,
    subscribe   => File["${env_dir}/conf/${ENV}.env"],
    refreshonly => true,
  }

  # DB Setup
  exec { 'cabot syncdb':
    command     => "bash -c '${source_activate}; ${foreman_run} ${env_dir}/bin/python manage.py syncdb --noinput'",# PYTHON NORMAL ??
    cwd         => $source_dir,
    subscribe   => Exec['cabot install'],
    refreshonly => true,
    path        => '/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin',
  }

# FAILS !!!
#  $create_user_code = "from django.contrib.auth.models import User; User.objects.create_superuser('${django_username}', '${admin_address}', '${django_password}')"
#  exec { 'cabot create user':
#    command     => "bash -c '${source_activate}; echo \"${create_user_code}\" | ${foreman_run} ${env_dir}/bin/python manage.py shell'",# PYTHON NORMAL ??
#    cwd         => $source_dir,
#    subscribe   => Exec['cabot syncdb'],
#    refreshonly => true,
#    path        => '/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin',
#  }

# foreman run -e /opt/cabot_venv/conf/development.env /opt/cabot_venv/bin/python manage.py createsuperuser --username root2 --email nicolas@truyens.com => REQUIRES PASSWORD !!!

  exec { 'cabot migrate cabotapp':
    command     => "bash -c '${source_activate}; ${foreman_run} ${env_dir}/bin/python manage.py migrate cabotapp --noinput'",# PYTHON NORMAL ??
    cwd         => $source_dir,
    subscribe   => Exec['cabot syncdb'],
    refreshonly => true,
    path        => '/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin',
  }

  exec { 'cabot migrate djcelery':
    command     => "bash -c '${source_activate}; ${foreman_run} ${env_dir}/bin/python manage.py migrate djcelery --noinput'",# PYTHON NORMAL ??
    cwd         => $source_dir,
    subscribe   => Exec['cabot migrate cabotapp'],
    refreshonly => true,
    path        => '/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin',
  }

  exec { 'cabot collectstatic':
    command     => "${foreman_run} ${env_dir}/bin/python manage.py collectstatic --noinput",
    cwd         => $source_dir,
    subscribe   => Exec['cabot migrate djcelery'],
    refreshonly => true,
    path        => '/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin',
  }

  exec { 'cabot compress':
    command     => "${foreman_run} ${env_dir}/bin/python manage.py compress",
    cwd         => $source_dir,
    subscribe   => Exec['cabot collectstatic'],
    refreshonly => true,
    path        => '/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin',
  }

  # FAILING !!! TODO    $procfile = "${source_dir}/Procfile"
  $procfile = "${source_dir}/Procfile.dev"
  $env_file = "${env_dir}/conf/${ENV}.env"
  $template = "${source_dir}/upstart"
  $user = 'root'  # TODO .?.

  exec { 'cabot init-script':
    command     => "bash -c 'export HOME=$source_dir; ${foreman} export upstart /etc/init -f ${procfile} -e ${env_file} -u ${user} -a cabot -t ${template}'",
    cwd         => $source_dir,
    subscribe   => Exec['cabot compress'],
    refreshonly => true,
    path        => '/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin',
  }

  service { 'cabot':
    ensure => running,
    # provider => upstart,
    require => Exec['cabot init-script'],
  }
}
