# Class: cabot::postgres
#
# Private class. Only calling cabot main class is supported.
#
# MODULE: puppetlabs/postgresql
class cabot::postgres {
  # Installation
  if ($cabot::install_postgres) {
    class { '::postgresql::server':
      listen_addresses        => $cabot::postgres_listen,
      ip_mask_allow_all_users => $cabot::postgres_ip_mask_allow,
    }
  }

  # Setup DB
  if ($cabot::setup_db) {
    postgresql::server::db { $cabot::db_database:
      user     => $cabot::db_username,
      password => postgresql_password($cabot::db_username, $cabot::db_password),
    }
  }
}
