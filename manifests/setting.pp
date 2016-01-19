# == Definition: cabo::setting
#
# Wrapper for ini_setting
#
# === Parameters:
# * ensure (string): present/absent. Default: present
# * value (string): the value to assign
#
# === Authors
#
# Nicolas Truyens <nicolas@truyens.com>
#
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
  File["${dir}/conf"] -> Ini_setting["cabot_${env}_${name}"] -> Anchor['cabot_config']
  Ini_setting["cabot_${env}_${name}"] ~> Service['cabot']
}
