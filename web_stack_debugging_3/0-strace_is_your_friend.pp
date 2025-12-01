# 0-strace_is_your_friend.pp
# Puppet manifest to fix Apache 500 error caused by permissions

# Ensure /var/www/html directory exists with correct ownership and permissions
file { '/var/www/html':
  ensure  => directory,
  owner   => 'www-data',
  group   => 'www-data',
  recurse => true,      # Apply settings to all files and subdirectories
  mode    => '0755',    # Directories readable/executable, files readable
}

# Ensure Apache service is running and enabled at boot
# Also restart automatically if /var/www/html changes
service { 'apache2':
  ensure    => running,
  enable    => true,
  subscribe => File['/var/www/html'],  # Restart Apache if files change
}

