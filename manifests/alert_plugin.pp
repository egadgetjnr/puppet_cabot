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
    ~> Exec['cabot install']    # TODO !!! - THIS NEEDS TO BE TESTED !!!
  }

  # Configuration
  create_resources('cabot::setting', $config)

  # Load plugin in main config  - TODO: Extensive testing (acceptance => need to check end result !!)
  if ($version == 'absent') {
    $ensure = 'absent'
  } else {
    $ensure = 'present'
  }

#  if ($version == 'present') {
#    @@ini_subsetting { "cabot_${env}_alert_plugins_${name}":
#      ensure               => $ensure,
#      path                 => "${virtualenv}/conf/${env}.env",
#      setting              => 'CABOT_PLUGINS_ENABLED',
#      subsetting           => "cabot_alert_${name}",
#      key_val_separator    => '==',
#      value                => $version,
#      subsetting_separator => ',',
#      tag                  => "cabot_${env}",# TODO PARAM
#    }
#  } else {

  ini_subsetting { "cabot_${env}_alert_plugins_${name}":
    ensure               => $ensure,
    path                 => "${virtualenv}/conf/${env}.env",
    setting              => 'CABOT_PLUGINS_ENABLED',
    subsetting           => "cabot_alert_${name}",
    key_val_separator    => '',
    value                => '',
    subsetting_separator => ',',
    # tag                  => "cabot_${env}",# TODO PARAM
  }

#  }
}
