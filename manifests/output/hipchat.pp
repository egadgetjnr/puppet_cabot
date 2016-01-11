# Class: cabot::output::hipchat
#
# Custom Configuration specific for Hipchat Alert Plugin
#
# Parameters:
# TODO
#
# Copyright 2016 - Nicolas Truyens
class cabot::output::hipchat (
  $room,
  $api_key,
  $api_url = 'https://api.hipchat.com/v1/rooms/message',
) {
  cabot::alert_plugin { 'hipchat':
    config => {
      'HIPCHAT_URL'        => {
        'value' => $api_url
      },
      'HIPCHAT_ALERT_ROOM' => {
        'value' => $room
      },
      'HIPCHAT_API_KEY'    => {
        'value' => $api_key
      },
    },
  }
}
