# Class: cabot::api
#
# This class manages the configuration file that Puppet uses to call the Cabot REST API.
#
# Parameters:
# * host (string): The host to call the API on. Default: 127.0.0.1 
# * port (integer): The port to call the API on. Default: 5000
# * user (string): The username to authenticate onthe API. Default: cabot
# * password (string): The password to authenticate onthe API.
# * users (hash): a hash of users and their ID as the API doesn't have this; eg.
#   { 1 => 'cabot', 2 => 'user1' }
# TODO - users hash must be retrievable somehow... This method is stupid !
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
  # TODO - validation  
  
  # Config file location is currently statically configured (cabot_rest.rb)
  $cabot_config_dir = '/etc/cabot'
  $api_auth_file = "${cabot_config_dir}/puppet_api.yaml"

  # How can I reach the REST API?
  $api_host = $host
  $api_port = $port
  # Who can I authenticate as?
  $admin_user = $user
  $admin_password = $password
  # List all users so Puppet can match username and ID
  $users_hash = $users

  file { $cabot_config_dir:
    ensure => 'directory',
  }
  ->
  file { $api_auth_file:
    ensure  => file,
    content => template('cabot/api.yaml.erb')
  }

  # Dependency Gems Installation 
  if versioncmp($::puppetversion, '4.0.0') < 0 {
    ensure_packages(['rest-client'], {'ensure' => 'present', 'provider' => 'gem'})
  } else {
    ensure_packages(['rest-client'], {'ensure' => 'present', 'provider' => 'puppet_gem'})
  }
}
