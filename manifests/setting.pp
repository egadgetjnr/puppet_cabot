# Definition: cabot::setting
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

  @@ini_setting { "cabot_${env}_${name}":
    ensure  => $ensure,
    path    => "${dir}/conf/${env}.env",
    setting => $name,
    value   => $value,
    tag     => "cabot_${env}",# TODO PARAM
  }
}
