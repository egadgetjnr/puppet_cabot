# Class: cabot::output::twilio
#
# Custom Configuration specific for Twilio Alert Plugin
#
# Parameters:
# TODO
#
# Copyright 2016 - Nicolas Truyens
class cabot::output::twilio (
  $account_sid,
  $auth_token,
  $outgoing_number,
) {
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
