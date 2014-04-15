Exec { path => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ] }
group { 'puppet':   ensure => present }
group { 'apache':   ensure => present }
group { 'vagrant':  ensure => present }

# add extra repos
yumrepo { "epel":
    baseurl => "http://download.fedoraproject.org/pub/epel/6/$architecture",
    descr => "Fedora epel repository",
    enabled => 1,
    gpgcheck => 0
}

yumrepo { "IUS":
    baseurl => "http://dl.iuscommunity.org/pub/ius/stable/Redhat/6/$architecture",
    descr => "IUS Community repository",
    enabled => 1,
    gpgcheck => 0
}

$wantedpackages = [
  "curl",
  "acl",
  "telnet",
  "tcpdump",
  "ntp",
  "ethtool",
  "git",
  "nano",
  "iptraf",
  "traceroute",
  "bind-utils",
  "strace",
  "lsof",
  "cronie",
  "wget",
  "hdparm",
  "ftp",
  "ncftp",
  "httpd",
  "php54",
  "php54-mysql",
  "php54-intl",
  "php54-xml",
  "php54-mbstring",
  "php54-pecl-apc",
  "php54-gd",
  "php54-soap",
  "mysql-server",
  "phpMyAdmin",
  "openvpn",
]

package { $wantedpackages:
    ensure => latest,
    require => Yumrepo["IUS", "epel"]
}

user { $::ssh_username:
  shell   => '/bin/bash',
  home    => "/home/${::ssh_username}",
  ensure  => present,
  groups  => ['apache', 'vagrant'],
  require => [Group['apache']]
}

file { "/home/${::ssh_username}":
    ensure => directory,
    owner  => $::ssh_username,
}

file { "/var/www/app.local/":
    ensure => "directory",
    group => "apache",
    require => Package["httpd"]
}

file { "/var/www/app.local/web":
    ensure => "link",
    target => "/vagrant/web",
    require => File["/var/www/app.local/"],
}

service { "mysqld":
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
    require => Package["mysql-server"],
    restart => true;
}

service { "httpd":
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
    require => [Package["httpd"] ],
    restart => true;
}

file { "/etc/httpd/conf/httpd.conf":
    notify  => Service["httpd"],
    require => Package["httpd"],
    mode => "0644",
    owner => 'root',
    group => 'root',
    source => 'puppet:///modules/flows/httpd.conf',
}

file { "/etc/php.ini":
    notify  => Service["httpd"],
    require => Package["httpd", "php54"],
    mode => "0644",
    owner => 'root',
    group => 'root',
    source => 'puppet:///modules/flows/php.ini',
}

file { "/etc/phpMyAdmin/config.inc.php":
    require => Package["httpd", "phpMyAdmin"],
    notify  => Service["httpd"],
    mode => "0644",
    owner => 'root',
    group => 'root',
    source => 'puppet:///modules/phpmyadmin/config.inc.php',
}

file { "/etc/httpd/conf.d/phpMyAdmin.conf":
    require => Package["httpd", "phpMyAdmin"],
    notify  => Service["httpd"],
    mode => "0644",
    owner => 'root',
    group => 'root',
    source => 'puppet:///modules/phpmyadmin/phpMyAdmin.conf',
}

service { "iptables":
    ensure => stopped,
    enable => false,
    hasstatus => true,
    hasrestart => true
}

file { "/tmp/symfony2":
    ensure => directory,
    owner  => 'apache',
    group  => 'apache',
    mode   => 0775,
    require => Service["httpd"],
}

exec { 'set_symfony2_permissions':
  command => "setfacl -R -m g:apache:rwX /tmp/symfony2 && setfacl -dR -m g:apache:rwX /tmp/symfony2",
  onlyif  => "test -d /tmp/symfony2",
  logoutput => "on_failure",
  require => File['/tmp/symfony2'],
  provider => shell,
}