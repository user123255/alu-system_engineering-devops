# 0-the_sky_is_the_limit_not.pp
# Puppet manifest to fix web stack for high concurrency testing with Nginx

# Ensure /var/www/html exists with correct permissions and removes old files
file { '/var/www/html':
  ensure  => directory,
  owner   => 'www-data',
  group   => 'www-data',
  recurse => true,
  purge   => true,
  force   => true,
  mode    => '0755',
}

# Ensure index.html exists with content for benchmarking
file { '/var/www/html/index.html':
  ensure  => file,
  owner   => 'www-data',
  group   => 'www-data',
  mode    => '0644',
  content => '<html><body><h1>Welcome to Nginx!</h1></body></html>',
}

# Install Nginx package
package { 'nginx':
  ensure => installed,
}

# Ensure Nginx service is running and enabled
service { 'nginx':
  ensure    => running,
  enable    => true,
  subscribe => File['/var/www/html'],
}

# Configure Nginx for high concurrency
file { '/etc/nginx/nginx.conf':
  ensure  => file,
  owner   => 'root',
  group   => 'root',
  mode    => '0644',
  content => @(END),
worker_processes auto;
events {
    worker_connections 1024;
}
http {
    server {
        listen 80;
        root /var/www/html;
        index index.html;
    }
}
END
  notify  => Service['nginx'],
}

