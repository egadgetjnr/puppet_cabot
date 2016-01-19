# == Class: cabot::output::twilio
#
# Custom Configuration specific for Twilio Alert Plugin
#
# === Parameters:
# * account_sid (string): Your Twilio SID
# * auth_token (string): Your Twilio Authentication Token 
# * outgoing_number (string): The number to use for outgoing comms
#
# === Authors
#
# Nicolas Truyens <nicolas@truyens.com>
#
class cabot::output::twilio (
  $account_sid,
  $auth_token,
  $outgoing_number,
) {
  # TODO - validation
  
  cabot::alert_plugin { 'twilio':
    config => {
      'TWILIO_ACCOUNT_SID'     => {
        'value' => $account_sid
      },
      'TWILIO_AUTH_TOKEN'      => {
        'value' => $auth_token
      },
      'TWILIO_OUTGOING_NUMBER' => {
        'value' => $outgoing_number
      },
    },
  }
}
