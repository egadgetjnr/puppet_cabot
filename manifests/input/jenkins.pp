# == Class: cabot::input::jenkins
#
# Custom Configuration specific for Jenkins input
#
# === Parameters:
# * host (string): The Jenkins Hostname
# * port (integer): The Jenkins Port
# * username (string): Username for logging into Jenkins (optional)
# * password (string): Password for logging into Jenkins (optional)
#
# === Authors
#
# Nicolas Truyens <nicolas@truyens.com>
#
class cabot::input::jenkins (
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

  cabot::custom_settings { 'jenkins':
    config => {
      'JENKINS_API'  => {
        'value' => "http://${host}:${port}/"
      },
      'JENKINS_USER' => {
        'value'  => $username,
        'ensure' => $auth
      },
      'JENKINS_PASS' => {
        'value'  => $password,
        'ensure' => $auth
      },
    },
  }
}
