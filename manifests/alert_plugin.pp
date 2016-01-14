# Definition: cabot::alert_plugin
#
# This definition installs a new alert plugin
#
# Parameters:
# TODO
#
# Copyright 2016 - Nicolas Truyens
define cabot::alert_plugin (
  # TODO PARAMS
  $url     = undef,
  $version = 'present',
  $config  = {},
) {
  $virtualenv = $::cabot::install_dir
  $env = $::cabot::environment

  # Installation
  if ($url != undef) {
    Python::Virtualenv[$virtualenv]
    ->
    python::pip { "cabot-alert-${name}" :
      ensure     => $version,
      url        => $url,
      virtualenv => $virtualenv,
    }
    ~> Exec['cabot install']
  }

  # Configuration
  create_resources('cabot::setting', $config)

  # Load plugin in main config (if not a system default)
  if ! member(['email', 'hipchat', 'twilio'], $name) {
    if ($version == 'absent' or $version == 'present') {
      $ensure = $version
      $pin = ''
      $use_exact_match = true
    } else {
      $ensure = 'present'
      $pin = "==${version}"
      $use_exact_match = false
    }

    # Exported version: @@ini_subsetting { "cabot_${env}_alert_plugins_${name}":
    ini_subsetting { "cabot_${env}_alert_plugins_${name}":
      ensure               => $ensure,
      path                 => "${virtualenv}/conf/${env}.env",
      key_val_separator    => '=',
      subsetting_separator => ',',
      setting              => 'CABOT_PLUGINS_ENABLED',
      subsetting           => "cabot_alert_${name}",
      value                => $pin,
      use_exact_match      => $use_exact_match,
      # Exported version: tag     => "cabot_${env}",# PARAM !!
    }

    # Not for exported version !
    File["${virtualenv}/conf"] -> Ini_subsetting["cabot_${env}_alert_plugins_${name}"] -> Anchor['cabot_config']
    Ini_subsetting["cabot_${env}_alert_plugins_${name}"] ~> Exec['cabot install']
  }
}
