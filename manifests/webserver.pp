# Class: cabot::webserver
#
# Private class. Only calling cabot main class is supported.
#
class cabot::webserver {
  # puppetlabs/apache

  if ($cabot::install_apache) {
    class { '::apache':
      default_vhost => false,
    }
  }

  if ($cabot::setup_apache) {
    apache::vhost { 'cabot':
      servername          => $cabot::webserver_hostname,
      port                => $cabot::webserver_port,

      manage_docroot      => false,
      docroot             => $cabot::source_dir,

      aliases             => [
        {
          alias => '/static/',
          path  => "${cabot::source_dir}/static/",
        },
      ],

      directories         => [
        {
          path           => '/static/',
          provider       => 'location',
          sethandler     => 'None',
          options        => [ 'All' ],
          #Apache 2.4 ONLY !! - auth_require   => 'all granted',
          allow_override => [ 'All' ],
        },
      ],

      proxy_preserve_host => true,
      proxy_pass          => [
        {
          'path' => '/static',
          'url'  => '!',
        },
        {
          'path' => '/',
          'url'  => "http://127.0.0.1:${cabot::port}/",
        },
      ],
    }
  }
}
