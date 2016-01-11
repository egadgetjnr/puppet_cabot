# Class: cabot::redis
#
# Private class. Only calling cabot main class is supported.
#
class cabot::redis inherits ::cabot {
  if ($cabot::install_redis) {
    # thomasvandoren/redis
    class { '::redis':
      redis_bind_address => $cabot::redis_bind_address,
      redis_port         => $cabot::redis_port,
      redis_password     => $cabot::redis_password,
      redis_max_memory   => $cabot::redis_tune_max_mem,
    }
  }
}
