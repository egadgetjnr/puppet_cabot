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
  $username,
  $password,
) {
  # TODO - validation
  
  cabot::custom_settings { 'jenkins':
    config => {
      'JENKINS_API'  => {
        'value' => "http://${host}:${port}/"
      },
      'JENKINS_USER' => {
        'value' => $username
      },
      'JENKINS_PASS' => {
        'value' => $password
      },
    },
  }
}
