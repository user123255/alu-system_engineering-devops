# 0-strace_is_your_friend.pp
# Fully automated fix for ALU web stack task

# 1️⃣ Ensure Apache is installed
package { 'apache2':
  ensure => installed,
}

# 2️⃣ Ensure PHP 8.3 and Apache PHP module are installed
package { ['php8.3', 'libapache2-mod-php8.3']:
  ensure => installed,
  require => Package['apache2'],
}

# 3️⃣ Enable PHP 8.3 module
exec { 'enable-php':
  command     => '/usr/sbin/a2enmod php8.3',
  path        => ['/usr/bin','/usr/sbin'],
  unless      => '/bin/ls /etc/apache2/mods-enabled | grep php8.3',
  require     => Package['libapache2-mod-php8.3'],
  notify      => Service['apache2'], # restart Apache if module changed
}

# 4️⃣ Ensure /var/www/html exists
file { '/var/www/html':
  ensure  => directory,
  owner   => 'www-data',
  group   => 'www-data',
  mode    => '0755',
}

# 5️⃣ Deploy correct index.php returning 12
file { '/var/www/html/index.php':
  ensure  => file,
  owner   => 'www-data',
  group   => 'www-data',
  mode    => '0644',
  content => "<?php echo 12; ?>\n",
  require => File['/var/www/html'],
}

# 6️⃣ Remove index.html if it exists to avoid conflicts
file { '/var/www/html/index.html':
  ensure => absent,
}

# 7️⃣ Ensure Apache is running and enabled
service { 'apache2':
  ensure    => running,
  enable    => true,
  subscribe => [ File['/var/www/html/index.php'], Exec['enable-php'] ],
}
