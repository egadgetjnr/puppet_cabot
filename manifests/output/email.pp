# Class: cabot::output::email
#
# Custom Configuration specific for E-Mail Alert Plugin
#
# Parameters:
# TODO
#
# Copyright 2016 - Nicolas Truyens
class cabot::output::email (
  $host,
  $port,
  $username = undef,
  $password = undef,
) {
  if ($username == undef) {
    $auth = 'absent'
  } else {
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
