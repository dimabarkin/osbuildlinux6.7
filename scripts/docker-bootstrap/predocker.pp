# pre-docker predocker.pp
# Based on https://docs.oracle.com/cd/E37670_01/E37355/html/section_kfy_f2z_fp.html#
# Based on Oracle® Linux Administrator's Solutions Guide for Release 6
# Updates kernel
exec{'/tmp/public-yum-ol6.repo':
  command => "/usr/bin/wget -q http://public-yum.oracle.com/public-yum-ol6.repo -O /tmp/public-yum-ol6.repo",
}
file { '/etc/yum.repos.d/public-yum-ol6.repo':
  source => "/tmp/public-yum-ol6.repo",
  require=> Exec['/tmp/public-yum-ol6.repo'],

}
ini_setting { 'ol6_UEKR3_latest':
  ensure  => present,
  path    => '/etc/yum.repos.d/public-yum-ol6.repo',
  section => 'ol6_UEKR3_latest',
  setting => 'enabled',
  value   => '0',
  key_val_separator => '=',
  require           => File['/etc/yum.repos.d/public-yum-ol6.repo'],
}
ini_setting { 'ol6_UEKR4':
  ensure            => present,
  path              => '/etc/yum.repos.d/public-yum-ol6.repo',
  section           => 'ol6_UEKR4',
  setting           => 'enabled',
  value             => '1',
  key_val_separator => '=',
  require           => Ini_setting['ol6_UEKR3_latest'],
}
