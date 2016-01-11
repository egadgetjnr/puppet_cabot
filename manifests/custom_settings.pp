# Definition: cabot::custom_settings
#
# This definition adds extra configuration
# Required for inputs: Jenkins/HTTP/Graphite
#
# Parameters:
# TODO
#
# Copyright 2016 - Nicolas Truyens
define cabot::custom_settings (
  # TODO PARAMS
  $config  = {},
) {
  create_resources('cabot::setting', $config)
}
