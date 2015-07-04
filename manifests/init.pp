# Class: cabot
#
# This module manages Arachnys Cabot
#
# Parameters:
# TODO
#
# Requires: see Modulefile
#
# Sample Usage:
#
class cabot (
  # TODO PARAMS

  # Cabot ENV
  $source_dir    = '/opt/cabot_source',
  $env_dir       = '/opt/cabot_venv',
  $environment   = 'development',
  $foreman       = '/usr/local/bin/foreman',
  $git_url       = 'https://github.com/arachnys/cabot.git',
  $port          = '5000',
  $timezone      = 'Etc/UTC',
  $log_dir       = '/var/log/cabot',

  # Django
  $django_secret = '2FL6ORhHwr5eX34pP9mMugnIOd3jzVuT45f7w430Mt5PnEwbcJgma0q8zUXNZ68A',
  $django_username = 'root',
  $django_password = 'cabot',
  $admin_address = 'admin@example.com',

  # PostgreSQL
  $install_postgres       = false,
  $install_postgres_devel = false,
  $setup_db               = true,
  $db_database            = 'cabot',
  $db_username            = 'cabot',
  $db_password            = 'cabot',
  $db_hostname            = 'localhost',
  $db_port                = '5432',

  # Install
  $install_gcc    = true,
  $install_git    = false,
  $install_ruby   = false,
  $install_python = false,
  $install_nodejs = false,

  # Redis
  $install_redis      = false,
  $redis_bind_address = false,
  $redis_port         = '6379',
  $redis_password     = false,
  $redis_tune_max_mem = '1gb',

  $redis_hostname     = 'localhost',
  $redis_database     = '1',

  # Webserver
  $install_apache     = false,
  $setup_apache       = true,
  $webserver_port     = 80,

  # Graphite
  $graphiteweb_host   = $::fqdn,
  $graphiteweb_port   = '80',
  $graphite_username  = '',
  $graphite_password  = '',

  # Alert Plugins
  $config_plugins_enabled = 'cabot_alert_hipchat==1.6.1,cabot_alert_twilio==1.1.4,cabot_alert_email==1.3.1',

  # Hipchat
  $config_hipchat_room_id = undef,
  $config_hipchat_api_key = undef,

  # SMTP
  $config_smtp_host = undef,
  $config_smtp_port = undef,
  $config_smtp_username = undef,
  $config_smtp_password = undef,

  # Sensu
  $sensu_port = '3030',

  # Flapjack

) inherits cabot::params {
  # Sub-classes
  contain cabot::postgres
  contain cabot::install
  contain cabot::configure
  contain cabot::redis
  contain cabot::webserver

  # Dependency Chain
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
