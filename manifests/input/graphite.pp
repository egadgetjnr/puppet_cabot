# Class: cabot::input::graphite
#
# Custom Configuration specific for Graphite input
#
# Parameters:
# TODO
#
# Copyright 2016 - Nicolas Truyens
class cabot::input::graphite (
  $host,
  $port,
  $username = undef,
  $password = undef,
  $from     = '-10min',
) {
  if ($username == undef) {
    $auth = 'absent'
  } else {
    $auth = 'present'
  }

  cabot::custom_settings { 'graphite':
    config => {
      'GRAPHITE_API'  => {
        'value' => "http://${host}:${port}/"
      },
      'GRAPHITE_USER' => {
        'value'  => $username,
        'ensure' => $auth
      },
      'GRAPHITE_PASS' => {
        'value'  => $password,
        'ensure' => $auth
      },
      'GRAPHITE_FROM' => {
        'value' => $from
      },
    },
  }
}
