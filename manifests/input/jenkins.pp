# Class: cabot::input::jenkins
#
# Custom Configuration specific for Jenkins input
#
# Parameters:
# TODO
#
# Copyright 2016 - Nicolas Truyens
class cabot::input::jenkins (
  $host,
  $port,
  $username,
  $password,
) {
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
