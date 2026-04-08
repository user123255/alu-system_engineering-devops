# 0-the_sky_is_the_limit_not.pp

# Stop Apache FIRST
service { 'apache2':
  ensure => stopped,
  enable => false,
}

# Install nginx BEFORE config
package { 'nginx':
  ensure => installed,
}

# Create web root file
file { '/var/www/html/index.html':
  ensure  => file,
  content => 'Hello World',
  require => Package['nginx'],
}

# Nginx configuration (must come AFTER install)
file { '/etc/nginx/nginx.conf':
  ensure  => file,
  content => @(END),
worker_processes auto;

events {
    worker_connections 4096;
    multi_accept on;
}

http {
    sendfile on;
    keepalive_timeout 65;

    server {
        listen 80;
        root /var/www/html;
        index index.html;
    }
}
END
  require => Package['nginx'],
  notify  => Service['nginx'],
}

# Ensure nginx runs LAST
service { 'nginx':
  ensure     => running,
  enable     => true,
  require    => Package['nginx'],
  subscribe  => File['/etc/nginx/nginx.conf'],
}
