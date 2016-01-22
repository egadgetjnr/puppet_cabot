# Class: cabot::api
#
# This class manages the configuration file that Puppet uses to call the Cabot REST API.
#
# Parameters:
# * host (string): The host to call the API on. Default: 127.0.0.1
# * port (integer): The port to call the API on. Default: 5000
# * user (string): The username to authenticate on the API. Default: cabot
# * password (string): The password to authenticate on the API.
#
# === Authors
#
# Nicolas Truyens <nicolas@truyens.com>
#
class cabot::api (
  $password,
  $user  = 'cabot',
  $host  = '127.0.0.1',
  $port  = 5000,
) {
  validate_string($host, $user, $password)

  # Config file location is currently statically configured (cabot_rest.rb)
  $cabot_config_dir = '/etc/cabot'
  $api_auth_file = "${cabot_config_dir}/puppet_api.yaml"
  $user_script = "${cabot_config_dir}/get_user_hash.py"

  # How can I reach the REST API?
  $api_host = $host
  $api_port = $port
  # Who can I authenticate as?
  $admin_user = $user
  $admin_password = $password
  # How can I call the script that fetches Django users?
  $cabot_install_dir = $::cabot::install_dir
  $cabot_environment = $::cabot::environment

  file { $cabot_config_dir:
    ensure => 'directory',
  }

  File[$cabot_config_dir] ->
  file { $api_auth_file:
    ensure  => file,
    content => template('cabot/api.yaml.erb')
  }

  # The API does not have an interface for user lookup and requires user ID rather than username.
  # Install custom (Python/Django) script to retrieve the users (ID => name)
  $cabot_source = $::cabot::source_dir

  File[$cabot_config_dir] ->
  file { $user_script:
    ensure  => file,
    mode    => '0755',
    content => template('cabot/get_user_hash.py.erb')
  }

  # Dependency Gems Installation
  if versioncmp($::puppetversion, '4.0.0') < 0 {
    ensure_packages(['rest-client'], {'ensure' => 'present', 'provider' => 'gem'})
  } else {
    ensure_packages(['rest-client'], {'ensure' => 'present', 'provider' => 'puppet_gem'})
  }
}
