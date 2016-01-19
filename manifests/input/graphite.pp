# == Class: cabot::input::graphite
#
# Custom Configuration specific for Graphite input
#
# === Parameters:
# * host (string): The Graphite(Web) Hostname
# * port (integer): The Graphite(Web) Port 
# * username (string): Username for logging into GraphiteWeb (optional)
# * password (string): Password for logging into GraphiteWeb (optional)
# * from (string): The timeframe for which the graph should be pulled. Default: -10min
#
# === Authors
#
# Nicolas Truyens <nicolas@truyens.com>
#
class cabot::input::graphite (
  $host,
  $port,
  $username = undef,
  $password = undef,
  $from     = '-10min',
) {
  # TODO - validation
  
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
