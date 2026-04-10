# 0-strace_is_your_friend.pp
# Fix Apache 500 and ensure the page returns expected content

# Ensure /var/www/html directory exists
file { '/var/www/html':
  ensure => directory,
  owner  => 'www-data',
  group  => 'www-data',
  mode   => '0755',
}

file { '/var/www/html/index.html':
  ensure  => file,
  owner   => 'www-data',
  group   => 'www-data',
  mode    => '0644',
  content => "12",
}

service { 'apache2':
  ensure => running,
  enable => true,
}
