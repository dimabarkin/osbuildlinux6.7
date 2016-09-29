#umount /u01 /u02;rm -fR /u01 /u02;lvremove /dev/oradata1vg /dev/oradata2vg -f
#pvremove /dev/sdb /dev/sdc --force --force
#cd /vagrant;puppet apply puppet/manifests/site.pp --modulepath=puppet/modules --verbose --hiera_config /vagrant/puppet/hiera.yaml --parser future -detailed-exitcodes
info 'Installing packages: Begin'
#Based on repotrack -a x86_64 /software/OEL6_121_RPM oracle-rdbms-server-12cR1-preinstall
$all_packages = hiera('packages')
$all_packages.each |$package| {
  info "Installing packages ${package['order']} ${package['name']}"
  package { $package['name']:
    ensure  => 'installed',
    provider => 'yum',
  }
}
info 'Installing packages: End'
info 'Setting kernel: Begin'

$all_kernel = hiera('kernel_setting')
$all_kernel.each |$kernel| {
  sysctl { $kernel['name']:
             ensure => 'present', 
             permanent => 'yes', 
             value => $kernel['value'],}
}
info 'Setting kernel: End'

info 'Setting groups: Begin'

$all_groups = hiera('os_groups')
$all_groups.each |$group| {
 group { $group["name"] :
     ensure      => present,
     gid         => $group["gid"],
       }
}
info 'Setting groups: End'

info 'Setting users: Begin'
$all_users = hiera('os_users')

$all_users.each |$database_user| {
user { $database_user["name"] :
    ensure      => present,
    uid         => $database_user["uid"],
    gid         => $database_user["gid"],
    groups      => $database_user["groups"],
    shell       => '/bin/bash',
    password    => $database_user["password"],
    home        => $database_user["home"],
    comment     => $database_user["comment"],
    require     => Group[$database_user["groups"]],
    managehome  => true,
  }
}

info 'Setting users: End'
info 'Setting limits: Begin'
include limits
info 'Setting limits: End'
info 'Setting mount points: Begin'
include lvm
info 'Setting mount points: End'

class set_directories {
  $all_directories = hiera('directories')
  $all_directories.each |$directory| { 
  file { $directory["name"]:
   ensure => directory,
   owner => $directory["owner"],
   group => $directory["group"],
   mode => $directory["mode"],
   }
  } 
}

class set_permissions {
  $all_directories1 = hiera('directories')
  $all_directories1.each |$directory| { 
   exec { "fix_mount_perms_${directory['name']}":
     command => "chmod ${directory['mode']} ${directory['name']}",
     path => '/bin',
   }
   exec { "fix_mount_ownership_${directory['name']}":
     command => "chown ${directory['owner']}.${directory['group']} ${directory['name']} ",
     path => '/bin',     
   }
  } 
}
class set_filesystems {
  require set_directories
  include lvm
  include set_permissions
  Class['lvm'] ~> Class['set_permissions']
}

include set_filesystems
