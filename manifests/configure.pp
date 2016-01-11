# Class: cabot::configure
#
# Private class. Only calling cabot main class is supported.
#
class cabot::configure inherits ::cabot {
  # Python Virtual Environment
  python::virtualenv { $cabot::install_dir :
    ensure => 'present',
  }


  # Log Configuration
  file { $cabot::log_dir:
    ensure  => 'directory',
  }

  if ($cabot::setup_logrotate) {
    logrotate::rule { 'cabot':
      path          => "${cabot::log_dir}/*.log",
      compress      => true,
      delaycompress => true,
      rotate        => '12',      # TODO PARAM? - NEEDS TO BE STRING (for now)
      rotate_every  => 'week',    # TODO PARAM?
    }
  }
  # TODO - future parser when using logrotate::rule ???
    # Error: Evaluation Error: Error while evaluating a Function Call, Logrotate::Rule[cabot]: rotate must be an integer at /etc/puppetlabs/code/environments/production/modules/logrotate/manifests/rule.pp:306:7 on node ubuntu-14-04


  # Configuration
  $config_dir = "${cabot::install_dir}/conf"
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

  # TODO !!! - Test whether that is the correct exec and how exec should be chained
  # TODO - Tag should be param
  File["${cabot::install_dir}/conf"] -> Ini_setting <<| tag == "cabot_${environment}" |>> ~> Exec['cabot install']


  # Compilation
  $config_file = "${cabot::config_dir}/${environment}.env"
  $path = '/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin'
  $foreman = "foreman run -e ${cabot::config_file}"
  $activate = "source ${cabot::install_dir}/bin/activate"
  $manage = "${activate}; ${foreman} ${cabot::install_dir}/bin/python manage.py"

  # Step 1 - Install (downloads dependencies if required)
  # Timeout was changed to 300 (seconds) to allow downloading on slower links
  # ALWAYS called if configuration changes # TODO - verify the need for that...
  exec { 'cabot install':
    command     => "${foreman} ${cabot::install_dir}/bin/pip install --timeout=300 --editable ${cabot::source_dir} --exists-action=w",
    cwd         => $cabot::install_dir,
    refreshonly => true,
    path        => $path,
  } ~> Exec['cabot syncdb']   # TODO - verify the need for that...

  # Step 2 - Database Sync/Migrate
  exec { 'cabot syncdb':
    command     => "bash -c '${manage} syncdb --noinput'",# TODO - why bash, why activate, ... => python helpers?
    cwd         => $cabot::source_dir,
    refreshonly => true,
    path        => $path,
  } ~> Exec['cabot migrate cabotapp']   # TODO - verify the need for that...

  # Step 3 - Migrations
  # A - cabotapp
  exec { 'cabot migrate cabotapp':
    command     => "bash -c '${manage} migrate cabotapp --noinput'",# TODO - why bash, why activate, ... => python helpers?
    cwd         => $cabot::source_dir,
    refreshonly => true,
    path        => $path,
  } ~> Exec['cabot migrate djcelery']   # TODO - verify the need for that...

  # B - djcelery
  exec { 'cabot migrate djcelery':
    command     => "bash -c '${manage} migrate djcelery --noinput'",# TODO - why bash, why activate, ... => python helpers?
    cwd         => $cabot::source_dir,
    refreshonly => true,
    path        => $path,
  } ~> Exec['cabot collectstatic']   # TODO - verify the need for that...

  # Step 4 - Static Data
  exec { 'cabot collectstatic':
    command     => "${foreman} ${cabot::install_dir}/bin/python manage.py migrate collectstatic --noinput'",# TODO - why bash, why activate, ... => python helpers?
    cwd         => $cabot::source_dir,
    refreshonly => true,
    path        => $path,
  } ~> Exec['cabot compress']   # TODO - verify the need for that...

  exec { 'cabot compress':
    command     => "${foreman} ${cabot::install_dir}/bin/python manage.py migrate compress",# TODO - why no bash/activate here ???
    cwd         => $cabot::source_dir,
    refreshonly => true,
    path        => $path,
  }

  # Step 5 - Init Script
  if ($environment == 'development') {
    $procfile = "${cabot::source_dir}/Procfile.dev"
  } else {
    $procfile = "${cabot::source_dir}/Procfile"
  }
  $template = "${cabot::source_dir}/upstart"

  exec { 'cabot init-script':
    command     => "bash -c 'export HOME=${cabot::source_dir}; ${foreman} export upstart /etc/init -f ${procfile} -e ${config_file} -u ${cabot::user} -a cabot -t ${template}'",# TODO -a ??
    cwd         => $cabot::source_dir,
    refreshonly => true,
    path        => $path,
  } ~> Service['cabot']   # TODO - makes sense... ?

  Exec['cabot init-script']
  ->
  service { 'cabot':
    ensure => running,
  }

  # Administrators...
  # TODO MANUAL RUN FOR NOW:
  # cd /opt/cabot_source/; foreman run -e /opt/cabot_venv/conf/development.env /opt/cabot_venv/bin/python /opt/cabot_source/manage.py createsuperuser --username root2 --email ADDRESS

  # Option 1 (FAIL)
    # $create_user_code = "from django.contrib.auth.models import User; User.objects.create_superuser('root2', 'ADDRESS', 'cabot')"
    # bash -c '${activate}; echo \"${create_user_code}\" | ${foreman} ${install_dir}/bin/python manage.py shell'
}

