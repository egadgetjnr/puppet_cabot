# Class: cabot::configure::plugins
#
# Private class. Only calling cabot main class is supported.
#
class cabot::configure::plugins {
  # The default alert plugins are hard dependencies! [https://github.com/arachnys/cabot/issues/188]

  $virtualenv = $::cabot::install_dir
  $env = $::cabot::environment

  # Exported version: @@ini_subsetting { "cabot_${env}_alert_plugins_email":
  ini_subsetting { "cabot_${env}_alert_plugins_email":
    ensure               => 'present',
    path                 => "${virtualenv}/conf/${env}.env",
    key_val_separator    => '=',
    subsetting_separator => ',',
    setting              => 'CABOT_PLUGINS_ENABLED',
    subsetting           => 'cabot_alert_email',
    value                => '',
    use_exact_match      => true,
    # Exported version: tag     => "cabot_${env}",# PARAM !!
  }

  # Exported version: @@ini_subsetting { "cabot_${env}_alert_plugins_hipchat":
  ini_subsetting { "cabot_${env}_alert_plugins_hipchat":
    ensure               => 'present',
    path                 => "${virtualenv}/conf/${env}.env",
    key_val_separator    => '=',
    subsetting_separator => ',',
    setting              => 'CABOT_PLUGINS_ENABLED',
    subsetting           => 'cabot_alert_hipchat',
    value                => '',
    use_exact_match      => true,
    # Exported version: tag     => "cabot_${env}",# PARAM !!
  }

  # Exported version: @@ini_subsetting { "cabot_${env}_alert_plugins_twilio":
  ini_subsetting { "cabot_${env}_alert_plugins_twilio":
    ensure               => 'present',
    path                 => "${virtualenv}/conf/${env}.env",
    key_val_separator    => '=',
    subsetting_separator => ',',
    setting              => 'CABOT_PLUGINS_ENABLED',
    subsetting           => 'cabot_alert_twilio',
    value                => '',
    use_exact_match      => true,
    # Exported version: tag     => "cabot_${env}",# PARAM !!
  }
}

