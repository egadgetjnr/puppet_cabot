# == Definition: cabot::alert_plugin
#
# This definition installs a new alert plugin
#
# === Parameters:
# * url (string): If your are installing a new plugin, enter the GIT URL
# * version (string): present/absent or specific version of the plugin (= git tag) - Default: present 
# * config (hash): Config Hash - eg. { 'PARAM_1'  => {'value' => '<VALUE>'},}
#
# === Authors
#
# Nicolas Truyens <nicolas@truyens.com>
#
define cabot::alert_plugin (
  $url     = undef,
  $version = 'present',
  $config  = {},
) {
  $virtualenv = $::cabot::install_dir
  $env = $::cabot::environment
  
  # TODO - validation  

  # Installation
  if ($url != undef) {
    Python::Virtualenv[$virtualenv]
    ->
    python::pip { "cabot-alert-${name}" :
      ensure     => $version,
      url        => $url,
      virtualenv => $virtualenv,
    }
    ~> Exec['cabot install']
  }

  # Configuration
  create_resources('cabot::setting', $config)

  # Load plugin in main config (if not a system default)
  if ! member(['email', 'hipchat', 'twilio'], $name) {
    if ($version == 'absent' or $version == 'present') {
      $ensure = $version
      $pin = ''
      $use_exact_match = true
    } else {
      $ensure = 'present'
      $pin = "==${version}"
      $use_exact_match = false
    }

    # Exported version: @@ini_subsetting { "cabot_${env}_alert_plugins_${name}":
    ini_subsetting { "cabot_${env}_alert_plugins_${name}":
      ensure               => $ensure,
      path                 => "${virtualenv}/conf/${env}.env",
      key_val_separator    => '=',
      subsetting_separator => ',',
      setting              => 'CABOT_PLUGINS_ENABLED',
      subsetting           => "cabot_alert_${name}",
      value                => $pin,
      use_exact_match      => $use_exact_match,
      # Exported version: tag     => "cabot_${env}",# PARAM !!
    }

    # Not for exported version !
    File["${virtualenv}/conf"] -> Ini_subsetting["cabot_${env}_alert_plugins_${name}"] -> Anchor['cabot_config']
    Ini_subsetting["cabot_${env}_alert_plugins_${name}"] ~> Exec['cabot install']
  }
}
