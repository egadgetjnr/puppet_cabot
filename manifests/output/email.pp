# == Class: cabot::output::email
#
# Custom Configuration specific for E-Mail Alert Plugin
#
# === Parameters:
# * host (string): The SMTP Server Hostname
# * port (integer): The SMTP Server Port
# * username (string): Username for logging into SMTP Server (optional)
# * password (string): Password for logging into SMTP Server (optional)
#
# === Authors
#
# Nicolas Truyens <nicolas@truyens.com>
#
class cabot::output::email (
  $host,
  $port,
  $username = undef,
  $password = undef,
) {
  validate_string($host)

  if ($username == undef) {
    $auth = 'absent'
  } else {
    validate_string($username, $password)
    $auth = 'present'
  }

  # E-Mail (SMTP) - Requires SSL !!!
  cabot::alert_plugin { 'email':
    config => {
      'SES_HOST' => {
        'value' => $host
      },
      'SES_PORT' => {
        'value' => $port
      },
      'SES_USER' => {
        'value'  => $username,
        'ensure' => $auth
      },
      'SES_PASS' => {
        'value'  => $password,
        'ensure' => $auth
      },
    },
  }
}
