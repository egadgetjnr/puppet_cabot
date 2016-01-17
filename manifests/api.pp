# Class: cabot::api
#
# This class manages the configuration file that Puppet uses to call the Cabot REST API.
#
# Parameters:
# TODO
#
# === Authors
#
# Nicolas Truyens <nicolas@truyens.com>
#
class cabot::api (
  $password,
  $user  = 'cabot',
  $host  = '127.0.0.1',
  $port  = '5000',
  $users = {},
) {
  # Config file location is currently statically configured (cabot_rest.rb)
  $cabot_config_dir = '/etc/cabot'
  $api_auth_file = "${cabot_config_dir}/puppet_api.yaml"

  # How can I reach the REST API?
  $api_host = $host
  $api_port = $port
  # Who can I authenticate as?
  $admin_user = $user
  $admin_password = $password
  # List all users so Puppet can match username and ID - TODO FIX LATER
  $users_hash = $users

  file { $cabot_config_dir:
    ensure => 'directory',
  }
  ->
  file { $api_auth_file:
    ensure  => file,
    content => template('cabot/api.yaml.erb')
  }

  ensure_packages(['rest-client'], {'ensure' => 'present', 'provider' => 'gem'})
}
