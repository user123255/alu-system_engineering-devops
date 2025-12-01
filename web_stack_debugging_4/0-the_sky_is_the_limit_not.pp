# 0-the_sky_is_the_limit_not.pp
# Puppet manifest to optimize Nginx for high concurrency and fix failed requests

# Ensure /var/www/html exists with proper ownership and permissions
file { '/var/www/html':
  ensure  => directory,
  owner   => 'www-data',
  group   => 'www-data',
  recurse => true,
  purge   => true,
  force   => true,
  mode    => '0755',
}

# Ensure index.html exists with enough content for the benchmark
file { '/var/www/html/index.html':
  ensure  => file,
  owner   => 'www-data',
  group   => 'www-data',
  mode    => '0644',
  content => "<html><body><h1>Welcome to Nginx!</h1></body></html>",
}

# Install and ensure Nginx is running
package { 'nginx':
  ensure => installed,
}

service { 'nginx':
  ensure    => running,
  enable    => true,
  subscribe => File['/var/www/html'],
}

# Optional: tune Nginx worker processes and connections for high concurrency
file { '/etc/nginx/nginx.conf':
  ensure  => file,
  owner   => 'root',
  group   => 'root',
  mode    => '0644',
  content => template('web_stack_debugging_4/nginx.conf.erb'), # custom tuned config
  notify  => Service['nginx'],
}

# Example: The nginx.conf template should include:
# worker_processes auto;
# events {
#     worker_connections 1024;
# }
# http {
#     server {
#         listen 80;
#         root /var/www/html;
#         index index.html;
#     }
# }

