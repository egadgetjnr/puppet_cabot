# == Definition: cabot::custom_settings
#
# This definition adds extra configuration
# Required for inputs: Jenkins/HTTP/Graphite
#
# === Parameters:
# * config (hash): Config Hash - eg. { 'PARAM_1'  => {'value' => '<VALUE>'},}
#
# === Authors
#
# Nicolas Truyens <nicolas@truyens.com>
#
define cabot::custom_settings (
  $config  = {},
) {
  create_resources('cabot::setting', $config)
}
