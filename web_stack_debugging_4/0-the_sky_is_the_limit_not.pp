# 0-the_sky_is_the_limit_not.pp
# Puppet manifest to fix Nginx web stack for high concurrency

# Stop Apache if it's running
service { 'apache2':
  ensure => stopped,
  enable => false,
}

# Ensure web root exists
file { '/var/www/html':
  ensure  => directory,
  owner   => 'www-data',
  group   => 'www-data',
  mode    => '0755',
}

# Ensure index file exists
file { '/var/www/html/index.html':
  ensure  => file,
  owner   => 'www-data',
  group   => 'www-data',
  mode    => '0644',
  content => '<html><body><h1>Welcome to Nginx!</h1></body></html>',
}

# Install Nginx
package { 'nginx':
  ensure => installed,
}

# Increase system file limits (IMPORTANT)
exec { 'increase_ulimit':
  command => '/bin/sh -c "ulimit -n 65535"',
}

# Optimized Nginx config
file { '/etc/nginx/nginx.conf':
  ensure  => file,
  owner   => 'root',
  group   => 'root',
  mode    => '0644',
  content => @(END),
worker_processes auto;
worker_rlimit_nofile 65535;

events {
    worker_connections 4096;
    multi_accept on;
}

http {
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;

    server {
        listen 80;
        root /var/www/html;
        index index.html;
    }
}
END
  notify => Service['nginx'],
}

# Ensure Nginx is running
service { 'nginx':
  ensure    => running,
  enable    => true,
  subscribe => File['/etc/nginx/nginx.conf'],
}
