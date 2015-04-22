# Class: cabot::postgres
#
# Private class. Only calling cabot main class is supported.
#
class cabot::postgres inherits ::cabot {
  # TODO MOVE TO MAIN CLASS
  $listen_addresses           = '*'
  $ip_mask_allow_all_users    = '0.0.0.0/0'

  # puppetlabs/postgresql
  # TODO if ()
  class { '::postgresql::server':
    listen_addresses        => $listen_addresses,
    ip_mask_allow_all_users => $ip_mask_allow_all_users,
  }

  # TODO if ()
  include ::postgresql::lib::devel

  # Setup DB
  # TODO if ()
  # TODO PARAMS !!
  postgresql::server::db { 'cabot':
    user     => 'cabot',
    password => postgresql_password('cabot', 'cabot'),
  }
}
