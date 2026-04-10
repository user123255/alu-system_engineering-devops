# 0-strace_is_your_friend.pp
# Fix WordPress 500 error by restoring missing wp-settings.php file

# Restore wp-settings.php if missing
exec { 'restore-wp-settings':
  command => 'cp /var/www/html/wp-settings.php.bak /var/www/html/wp-settings.php',
  path    => ['/bin', '/usr/bin'],
  onlyif  => 'test -f /var/www/html/wp-settings.php.bak && test ! -f /var/www/html/wp-settings.php',
}

# Ensure correct ownership for Apache
file { '/var/www/html':
  ensure  => directory,
  owner   => 'www-data',
  group   => 'www-data',
  recurse => true,
}

# Ensure Apache is running
service { 'apache2':
  ensure => running,
  enable => true,
}
