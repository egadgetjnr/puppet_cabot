# == Class: cabot::input::rota
#
# Custom Configuration specific for Rotation Schedule
#
# === Parameters:
# * url (string): URL to the Google Calender ICAL
#
# === Authors
#
# Nicolas Truyens <nicolas@truyens.com>
#
class cabot::input::rota (
  $url,
) {
  validate_string($url)

  cabot::custom_settings { 'rota':
    config => {
      'CALENDAR_ICAL_URL' => {
        'value' => $url
      },
    },
  }
}
