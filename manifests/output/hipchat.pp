# == Class: cabot::output::hipchat
#
# Custom Configuration specific for Hipchat Alert Plugin
#
# === Parameters:
# * room (string): The Hipchat Room to advertise to
# * api_key (string): Your HipChat API Key
# * api_url (string): API Endpoint - Default: https://api.hipchat.com/v1/rooms/message
#
# === Authors
#
# Nicolas Truyens <nicolas@truyens.com>
#
class cabot::output::hipchat (
  $room,
  $api_key,
  $api_url = 'https://api.hipchat.com/v1/rooms/message',
) {
  validate_string($room, $api_key, $api_url)

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
