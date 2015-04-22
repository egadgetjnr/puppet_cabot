# Class: cabot::postgres
#
# Private class. Only calling cabot main class is supported.
#
class cabot::postgres inherits ::cabot {
  # TODO MOVE TO MAIN CLASS
  $listen_addresses           = '*'
  $ip_mask_allow_all_users    = '0.0.0.0/0'

  # puppetlabs/postgresql
  if ($install_postgres) {
	  class { '::postgresql::server':
	    listen_addresses        => $listen_addresses,
	    ip_mask_allow_all_users => $ip_mask_allow_all_users,
	  }
  }

  # TODO MOVE TO POSTGRES PROFILE
  if ($install_postgres_devel) {
    class { '::postgresql::lib::devel':
      link_pg_config => true,
    }
  }

  # Setup DB
  if ($setup_db) {
    postgresql::server::db { $db_database:
	    user     => $db_username,
	    password => postgresql_password($db_username, $db_password),
	  }
  }
}
