# Class: cabot::redis
#
# Private class. Only calling cabot main class is supported.
#
class cabot::redis inherits ::cabot {
  # thomasvandoren/redis

  # TODO MOVE TO MAIN CLASS
  $bind_address = false
  $port = '6379'
  $password = false
  $tune_max_mem = '1gb'

  if ($install_redis) {
	  class { '::redis':
	    redis_bind_address => $bind_address,
	    redis_port         => $port,
	    redis_password     => $password,
	    redis_max_memory   => $tune_max_mem,
	  }
  }
}
