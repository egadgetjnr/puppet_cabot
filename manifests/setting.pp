# Definition: cabo::setting
#
# Wrapper for ini_setting
#
# Parameters:
# TODO
#
# Copyright 2016 - Nicolas Truyens
define cabot::setting (
  $value,
  $ensure = 'present',
) {
  $dir = $::cabot::install_dir
  $env = $::cabot::environment

  # Exported version: @@ini_setting { "cabot_${env}_${name}":
  ini_setting { "cabot_${env}_${name}":
    ensure            => $ensure,
    path              => "${dir}/conf/${env}.env",
    key_val_separator => '=',
    setting           => $name,
    value             => $value,
    # Exported version: tag     => "cabot_${env}",# PARAM !!
  }

  # Not for exported version !
  File["${cabot::install_dir}/conf"] -> Ini_setting["cabot_${env}_${name}"] -> Anchor['cabot_config']
  Ini_setting["cabot_${env}_${name}"] ~> Service['cabot']
}
