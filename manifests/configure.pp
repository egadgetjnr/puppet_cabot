# Class: cabot::configure
#
# Private class. Only calling cabot main class is supported.
#
class cabot::configure {
  # Python Virtual Environment
  python::virtualenv { $cabot::install_dir :
    ensure => 'present',
  }


  # Logging
  file { $cabot::log_dir:
    ensure  => 'directory',
  } -> Exec['cabot init-script']

  if ($cabot::setup_logrotate) {
    File[$cabot::log_dir]
    ->
    logrotate::rule { 'cabot':
      path          => "${cabot::log_dir}/*.log",
      compress      => true,
      delaycompress => true,
      rotate        => '12',      # TODO PARAM? - NEEDS TO BE STRING (for now)
      rotate_every  => 'week',    # TODO PARAM?
    }
  }


  # Configuration
  $config_dir = "${cabot::install_dir}/conf"
  $config_file = "${config_dir}/${cabot::environment}.env"

  Python::Virtualenv[$cabot::install_dir]
  ->
  file { $config_dir:
    ensure  => 'directory',
  }


  # General Settings
  $db_url = "postgres://${cabot::db_username}:${cabot::db_password}@${cabot::db_hostname}:${cabot::db_port}/${cabot::db_database}"

  if ($cabot::redis_password != false and $cabot::redis_password != undef) {
    validate_string($cabot::redis_password)
    $redis_prefix = ":${cabot::redis_password}@"
  } else {
    $redis_prefix = ''
  }
  $broker_url = "redis://${redis_prefix}${cabot::redis_hostname}:${cabot::redis_port}/${cabot::redis_database}"

  if ($cabot::callback_scheme == undef or $cabot::callback_url == undef) {
    $www_scheme = 'http'

    if ($cabot::setup_apache) {
      $www_http_host = "${cabot::webserver_hostname}:${cabot::webserver_port}"
    } else {
      $www_http_host = "${::fqdn}:${cabot::port}"
    }
  } else {
    $www_http_host = $cabot::callback_url
    $www_scheme = $cabot::callback_scheme
  }

  $configuration = {
    'VENV'                           => {'value' => $cabot::install_dir},
    'PORT'                           => {'value' => $cabot::port},
#    'DEBUG'                          => {'value' => 't'},        # TODO - PARAM ?
    'LOG_FILE'                       => {'value' => '/dev/null'}, # TODO - PARAM ?
    'TIME_ZONE'                      => {'value' => $cabot::timezone},
    'ADMIN_EMAIL'                    => {'value' => $cabot::admin_address},# TODO optional? - defaults to undef
    'CABOT_FROM_EMAIL'               => {'value' => $cabot::admin_address},# TODO optional? - defaults to undef
    'DJANGO_SETTINGS_MODULE'         => {'value' => 'cabot.settings'},
    'DJANGO_SECRET_KEY'              => {'value' => $cabot::django_secret},
    'DATABASE_URL'                   => {'value' => $db_url},
    'CELERY_BROKER_URL'              => {'value' => $broker_url},
    'WWW_HTTP_HOST'                  => {'value' => $www_http_host},
    'WWW_SCHEME'                     => {'value' => $www_scheme},
    'NOTIFICATION_INTERVAL'          => {'value' => $cabot::notification_interval},  # $notification_interval
    'ALERT_INTERVAL'                 => {'value' => $cabot::alert_interval},  # $alert_interval
    'CELERY_CLEAN_DB_DAYS_TO_RETAIN' => {'value' => $cabot::db_days_to_retain},  # $db_days_to_retain
  }
  create_resources('cabot::setting', $configuration)

  # Collect exported settings (not currently used)
  # File[$config_dir] -> Ini_setting <<| tag == "cabot_${environment}" |>> -> Anchor['cabot_config']
  # Ini_setting <<| tag == "cabot_${environment}" |>> ~> Service['cabot']
  anchor { 'cabot_config': }


  # Compilation
  $foreman = "foreman run -e ${config_file}"
  $activate = "source ${cabot::install_dir}/bin/activate"
  $manage = "${activate}; ${foreman} ${cabot::install_dir}/bin/python manage.py"

  # Bug? - Installing 'foreman' package with 'gem' provider installs foreman in the puppet path on puppet 4, rather than on the system gems path
  if versioncmp($::puppetversion, '4.0.0') < 0 {
    # Puppet 3 (?)
    $path = '/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin'
  } else {
    # Puppet 4 (?)
    $path = '/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/puppetlabs/puppet/bin/'
  }

  # Installation (downloads dependencies if required)
  Python::Virtualenv[$cabot::install_dir] ~> Exec['cabot install']

  exec { 'cabot install':
    command     => "${foreman} ${cabot::install_dir}/bin/pip install --timeout=3600 --editable ${cabot::source_dir} --exists-action=w",
    timeout     => '3600', # Default: 300
    cwd         => $cabot::install_dir,
    refreshonly => true,
    path        => $path,
    require     => Anchor['cabot_config'],
  }

  # Database Sync and Migrations
  Exec['cabot install'] ~> Exec['cabot syncdb']
  #Ini_setting["cabot_${cabot::environment}_LOG_FILE"] ~> Exec['cabot syncdb']
  Ini_setting["cabot_${cabot::environment}_DATABASE_URL"] ~> Exec['cabot syncdb']
  #Ini_setting["cabot_${cabot::environment}_CELERY_BROKER_URL"] ~> Exec['cabot syncdb']
  #Ini_setting["cabot_${cabot::environment}_CELERY_CLEAN_DB_DAYS_TO_RETAIN"] ~> Exec['cabot syncdb']
  Exec['cabot syncdb'] ~> Exec['cabot migrate cabotapp']
  Exec['cabot syncdb'] ~> Exec['cabot migrate djcelery']

  exec { 'cabot syncdb':
    command     => "bash -c '${manage} syncdb --noinput'",
    cwd         => $cabot::source_dir,
    refreshonly => true,
    path        => $path,
  }

  exec { 'cabot migrate cabotapp':
    command     => "bash -c '${manage} migrate cabotapp --noinput'",
    cwd         => $cabot::source_dir,
    refreshonly => true,
    path        => $path,
  }

  exec { 'cabot migrate djcelery':
    command     => "bash -c '${manage} migrate djcelery --noinput'",
    cwd         => $cabot::source_dir,
    refreshonly => true,
    path        => $path,
  }

  # Static Data
  Exec['cabot install'] ~> Exec['cabot collectstatic']
  Exec['cabot install'] ~> Exec['cabot compress']

  exec { 'cabot collectstatic':
    command     => "${foreman} ${cabot::install_dir}/bin/python manage.py collectstatic --noinput",
    cwd         => $cabot::source_dir,
    refreshonly => true,
    path        => $path,
  }

  exec { 'cabot compress':
    command     => "${foreman} ${cabot::install_dir}/bin/python manage.py compress",
    cwd         => $cabot::source_dir,
    refreshonly => true,
    path        => $path,
  }


  # Init Script
  Python::Virtualenv[$cabot::install_dir] ~> Exec['cabot init-script']
  Ini_setting["cabot_${cabot::environment}_PORT"] ~> Exec['cabot init-script']

  if ($cabot::environment == 'development') {
    $procfile = "${cabot::source_dir}/Procfile.dev"
  } else {
    $procfile = "${cabot::source_dir}/Procfile"
  }

  $template = "${cabot::source_dir}/upstart"

  exec { 'cabot init-script':
    command     => "bash -c 'export HOME=${cabot::source_dir}; foreman export upstart /etc/init -f ${procfile} -e ${config_file} -u ${cabot::user} -a cabot -t ${template}'",# TODO -a ??
    cwd         => $cabot::source_dir,
    refreshonly => true,
    path        => $path,
    require     => Anchor['cabot_config'],
  } ~> Service['cabot']

  service { 'cabot':
    ensure  => running,
    require => Exec['cabot init-script'],
  }


  # Administrators...
  # TODO MANUAL RUN FOR NOW:
  # cd /opt/cabot_source/; foreman run -e /opt/cabot_venv/conf/development.env /opt/cabot_venv/bin/python /opt/cabot_source/manage.py createsuperuser --username root2 --email ADDRESS

  # Option 1 (FAIL)
    # $create_user_code = "from django.contrib.auth.models import User; User.objects.create_superuser('root2', 'ADDRESS', 'cabot')"
    # bash -c '${activate}; echo \"${create_user_code}\" | ${foreman} ${install_dir}/bin/python manage.py shell'
}

