# Class: cabot
#
# This module manages Arachnys Cabot
#
# Parameters:
# TODO PARAMETERS...
#
# Requires: see README
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
  $db_port     = '5432',

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
  $version         = 'present',
  $source_url      = 'https://github.com/arachnys/cabot.git',
  $source_revision = 'master',

  # Configuration
    # Cabot
  $install_dir     = '/opt/cabot_venv',
  $log_dir         = '/var/log/cabot',

  $setup_logrotate = false,
  $rotate_every    = 'week',
  $rotate_count    = '12',

  $environment     = 'production',
  $port            = '5000',
  $debug           = false,
  $log_file        = '/dev/null',
  $timezone        = 'Etc/UTC',
  # REQUIRED
  $admin_address,
  # Should be changed in production
  $django_secret   = '2FL6ORhHwr5eX34pP9mMugnIOd3jzVuT45f7w430Mt5PnEwbcJgma0q8zUXNZ68A',

  $callback_scheme = undef,
  $callback_url    = undef,

    # Alert Parameters
  $notification_interval = 120, # (minutes) - WARNING
  $alert_interval        = 10,  # (minutes) - ERROR/CRITICAL

    # Administrator
  $admin_user = 'cabot',
  # REQUIRED
  $admin_password,

    # Maintenance
    # Patch 1: Custom config for Celery Task
  $db_days_to_retain     = 60, # Days to retain historical data, defaults to 60 in original code

    # Redis (Client Only)
  $redis_hostname     = 'localhost',
  $redis_database     = '1',

    # Redis (Client + Server)
  $redis_port         = '6379',
  $redis_password     = 'cabotusesredisforocelery',  # This should be changed!

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
  # TODO validation
  
  
  
  
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
