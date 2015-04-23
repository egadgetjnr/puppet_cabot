# Class: cabot::webserver
#
# Private class. Only calling cabot main class is supported.
#
class cabot::webserver inherits ::cabot {
  if ($install_apache) {
    # puppetlabs/apache
    class { '::apache':
      default_vhost => false,
    }
  }

  if ($setup_apache) {
	  apache::vhost { 'cabot':
	    servername          => $::fqdn,
	    port                => $webserver_port,

	    manage_docroot      => false,
	    docroot             => $source_dir,

	    aliases             => [
        {
	        alias => '/static/',
	        path  => "${source_dir}/static/",
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
          'url'   => '!',
        },
        {
          'path' => '/',
          'url'   => 'http://127.0.0.1:5000/',
        },
      ],
	  }
  }
}
