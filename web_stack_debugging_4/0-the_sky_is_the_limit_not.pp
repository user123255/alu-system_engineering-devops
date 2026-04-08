# 0-the_sky_is_the_limit_not.pp
# Puppet manifest to fix Nginx web stack to handle 100 concurrent requests without failing


# Stop Apache if it's running (to free port 80)
service { 'apache2':
  ensure => stopped,
  enable => false,
}

# Ensure /var/www/html exists and is clean
file { '/var/www/html':
  ensure  => directory,
  owner   => 'www-data',
  group   => 'www-data',
  recurse => true,
  purge   => true,
  force   => true,
  mode    => '0755',
}

# Ensure index.html exists with content
file { '/var/www/html/index.html':
  ensure  => file,
  content => '<html><body><h1>Welcome to Nginx!</h1></body></html>',
  owner   => 'www-data',
  group   => 'www-data',
  mode    => '0644',
}

# Install Nginx
package { 'nginx':
  ensure => installed,
}

# Configure Nginx for high concurrency
file { '/etc/nginx/nginx.conf':
  ensure  => file,
  owner   => 'root',
  group   => 'root',
  mode    => '0644',
  content => '
user www-data;
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
    keepalive_timeout 65;
    gzip on;
}
',
  notify  => Exec['reload-nginx'],
}

# Reload Nginx whenever the config changes
exec { 'reload-nginx':
  command     => '/etc/init.d/nginx reload',
  refreshonly => true,
}

# Ensure Nginx is running and enabled
service { 'nginx':
  ensure  => running,
  enable  => true,
  require => Package['nginx'],
}

