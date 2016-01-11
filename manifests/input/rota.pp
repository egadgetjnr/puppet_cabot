# Class: cabot::input::rota
#
# Custom Configuration specific for Rotation Schedule
#
# Parameters:
# TODO
#
# Copyright 2016 - Nicolas Truyens
class cabot::input::rota (
  $url,
) {
  cabot::custom_settings { 'rota':
    config => {
      'CALENDAR_ICAL_URL' => {
        'value' => $url
      },
    },
  }
}
