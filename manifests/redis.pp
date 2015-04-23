# Class: cabot::redis
#
# Private class. Only calling cabot main class is supported.
#
class cabot::redis inherits ::cabot {
  if ($install_redis) {
    # thomasvandoren/redis
	  class { '::redis':
	    redis_bind_address => $redis_bind_address,
	    redis_port         => $redis_port,
	    redis_password     => $redis_password,
	    redis_max_memory   => $redis_tune_max_mem,
	  }
  }
}
