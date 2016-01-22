# Class: cabot
#
# This module manages Arachnys Cabot
#
# Parameters:
# * install_postgres (boolean): Whether to install PostgreSQL Server with this module (not recommended). Default: false
# * postgres_listen (string): The IP addresses on which the PostgreSQL Server should listen. Default: '*'
# * postgres_ip_mask_allow (string): The IP addresses which are allowed to contact the PostgreSQL Server. Default: '0.0.0.0/0'
# * setup_db (boolean): Whether to setup PostgreSQL Database with this module (recommended). Default: false
# * db_database (string): The Database name. Default: 'cabot'
# * db_username (string): The Database user. Default: 'cabot'
# * db_password (string): The Database password. Default: 'cabot'
# * db_hostname (string): The Database server to contact:  Default: 'localhost'
# * db_port (integer): The port on which to contact the Database. Default: 5432
# * install_gcc (boolean): Whether to install GCC with this module (not recommended). Default: false
# * install_git (boolean): Whether to install Git with this module (not recommended). Default: false
# * install_ruby (boolean): Whether to install Ruby with this module (not recommended). Default: false
# * install_python (boolean): Whether to install Python with this module (not recommended). Default: false
# * install_nodejs (boolean): Whether to install NodeJS with this module (not recommended). Default: false
# * install_dependencies (boolean): Whether to install dependency packages (deb/rpm) with this module (recommended). Default: true
# * install_gem_packages (boolean): Whether to install dependency packages (gem) with this module (recommended). Default: true
# * install_npm_packages (boolean): Whether to install dependency packages (npm) with this module (recommended). Default: true
# * user (string): The user that cabot runs as. This module does not create any users! Default: 'root'
# * source_dir (string): The directory in which the cabot source is stored. Default: '/opt/cabot_source'
# * source_url (string): The Git repository where to get Cabot from. Default: 'https://github.com/arachnys/cabot.git'
# * source_revision (string): The Git branch/tag/commit to retrieve. Default: 'master'
# * install_dir (string): The directory in which the cabot virtualenv is created. Default: '/opt/cabot_venv'
# * log_dir (string): The directory to create for logging. This directory is currently not set in configuration!!! Default: '/var/log/cabot'
# * setup_logrotate (boolean): Whether to include logrotate module and set up rule for cabot (recommended). Default: false
# * rotate_every (string): Frequency of logrotation. Allowed: day/week/month/year. Default: 'week'
# * rotate_count (integer): Archive count of logrotation. Default: 12
# * environment (string): Environment. Allowed: development/production. Default: 'production'
# * port (integer): The port that Cabot listens on natively. Default: 5000
# * debug (boolean): Whether to use Debugging mode. Default: false
# * log_file (string): The log file in the configuration. Currently not used by code. Default: '/dev/null'
# * timezone (string): Your Timezone. [Recommended Change]. Default: 'Etc/UTC'
# * admin_address (string): E-mail address for the administrator. [REQUIRED]
# * django_secret (string): Hash key used for comms with Django. [Recommended Change] Default: '2FL6ORhHwr5eX34pP9mMugnIOd3jzVuT45f7w430Mt5PnEwbcJgma0q8zUXNZ68A'
# * callback_scheme (string): In case you want to change the default URL published in alerts, change scheme here. Allowed: http/https
# * callback_url (string): In case you want to change the default URL published in alerts, change hostname here.
# * notification_interval (integer): The interval (in minutes) for alerts in WARNING state. Default: 120
# * alert_interval (integer): The interval (in minutes) for alerts in ERROR/CRITICAL state. Default: 10
# * admin_user (string): The first user to create (superuser). Default: 'cabot'
# * admin_password (string): The password for the first created superuser. [REQUIRED]
# * db_days_to_retain (integer): The number of days to retain information in the database. Default: 60
# * redis_hostname (string): The hostname to contact for Redis. Default: 'localhost'
# * redis_database (integer): The Redis database to use. Default: 1
# * redis_port (integer): The port used for Redis communication. Default: 6379
# * redis_password (string): The password to use for Redis communication. [Recommended Change] Default: 'cabotusesredisforocelery'
# * install_redis (boolean): Whether to install Redis with this module (not recommended). Default: false
# * redis_bind_address (string): The address to bind Redis on. Default: '127.0.0.1'
# * redis_tune_max_mem (string): The maximum memory the Redis server can consume. Default: '1gb'
# * install_apache (boolean): Whether to install Apache with this module (not recommended). Default: false
# * setup_apache (boolean): Whether to configure an Apache VirtualHost with this module (recommended). Default: false
# * webserver_hostname (string): The hostname of the virtual directory that redirects to Cabot. Default: $::fqdn
# * webserver_port (integer): The port of the virtual directory that redirects to Cabot. Default: 80
#
# === Dependencies/Requirements
# see README
#
# === Authors
#
# Nicolas Truyens <nicolas@truyens.com>
#
class cabot (
  # PostgreSQL
  $install_postgres       = false,
  $postgres_listen        = '*',
  $postgres_ip_mask_allow = '0.0.0.0/0',

  $setup_db    = false,
  $db_database = 'cabot',
  $db_username = 'cabot',
  $db_password = 'cabot',
  $db_hostname = 'localhost',
  $db_port     = 5432,

  # Install
  $install_gcc    = false,
  $install_git    = false,
  $install_ruby   = false,
  $install_python = false,
  $install_nodejs = false,

  $install_dependencies = true,
  $install_gem_packages = true,
  $install_npm_packages = true,

    # Cabot
  $user            = 'root',
  $source_dir      = '/opt/cabot_source',
  $source_url      = 'https://github.com/arachnys/cabot.git',
  $source_revision = 'master',

  # Configuration
    # Cabot
  $install_dir = '/opt/cabot_venv',
  $log_dir     = '/var/log/cabot',

  $setup_logrotate = false,
  $rotate_every    = 'week',
  $rotate_count    = 12,

  $environment   = 'production',
  $port          = 5000,
  $debug         = false,
  $log_file      = '/dev/null',
  $timezone      = 'Etc/UTC',
  # REQUIRED
  $admin_address,
  # Should be changed in production
  $django_secret = '2FL6ORhHwr5eX34pP9mMugnIOd3jzVuT45f7w430Mt5PnEwbcJgma0q8zUXNZ68A',

  $callback_scheme = undef,
  $callback_url    = undef,

    # Alert Parameters
  $notification_interval = 120, # (minutes) - WARNING
  $alert_interval        = 10,  # (minutes) - ERROR/CRITICAL

    # Administrator
  $admin_user     = 'cabot',
  # REQUIRED
  $admin_password,

    # Maintenance
    # Patch 1: Custom config for Celery Task
  $db_days_to_retain = 60, # Days to retain historical data, defaults to 60 in original code

    # Redis (Client Only)
  $redis_hostname = 'localhost',
  $redis_database = 1,
    # Redis (Client + Server)
  $redis_port     = 6379,
  $redis_password = 'cabotusesredisforocelery',  # This should be changed!

  # Redis (Server)
  $install_redis      = false,
  $redis_bind_address = '127.0.0.1',
  $redis_tune_max_mem = '1gb',

  # Webserver
  $install_apache     = false,
  $setup_apache       = false,
  $webserver_hostname = $::fqdn,
  $webserver_port     = 80,
) {
  validate_bool($install_postgres, $setup_db)
  validate_bool($install_gcc, $install_git, $install_ruby, $install_python, $install_nodejs)
  validate_bool($install_dependencies, $install_gem_packages, $install_npm_packages)
  validate_bool($setup_logrotate, $debug, $install_redis, $install_apache, $setup_apache)

  validate_string($postgres_listen, $postgres_ip_mask_allow)
  validate_string($db_database, $db_username, $db_password, $db_hostname)
  validate_string($user, $source_url, $source_revision, $timezone, $django_secret)
  validate_string($admin_address, $admin_user, $admin_password, $webserver_hostname)
  validate_string($redis_hostname, $redis_bind_address, $redis_tune_max_mem)

  validate_absolute_path($source_dir, $install_dir, $log_dir, $log_file)

  validate_re($rotate_every, ['day', 'week', 'month', 'year'])
  validate_re($environment, ['development', 'production'])

  # Sub-classes
  include cabot::postgres
  include cabot::install
  include cabot::configure
  include cabot::redis
  include cabot::webserver

  # Dependency Chain
  Class['::cabot']
  ->
  Class['cabot::postgres']
  ->
  Class['cabot::install']
  ->
  Class['cabot::configure']
  ->
  Class['cabot::redis']
  ->
  Class['cabot::webserver']
}
