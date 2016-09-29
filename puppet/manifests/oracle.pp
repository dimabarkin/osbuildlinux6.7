#cd /vagrant;puppet apply puppet/manifests/oracle.pp --modulepath=puppet/modules --verbose --hiera_config /vagrant/puppet/hiera.yaml --parser future --debug
node 'oel67bare.example.com' {
  include oradb_os
  include oradb_cdb
}

Package{allow_virtual => false,}

class oradb_os {
  class { 'swap_file':
    swapfile     => '/var/swap.1',
    swapfilesize => '8192000000',
  }

  mount { '/dev/shm':
    ensure      => present,
    atboot      => true,
    device      => 'tmpfs',
    fstype      => 'tmpfs',
    options     => 'size=2000m',
  }

  $host_instances = hiera('hosts', {})
  create_resources('host',$host_instances)

  service { iptables:
    enable    => false,
    ensure    => false,
    hasstatus => true,
  }
}

class oradb_cdb {
  require oradb_os
    oradb::installdb{ 'db_linux-x64':
      version                   => "12.1.0.2",
      file                      => "linuxamd64_12102_database",
      database_type             => 'EE',
      ora_inventory_dir         => hiera('oraInventory_dir'),
      oracle_base               => hiera('oracle_base_dir'),
      oracle_home               => hiera('oracle_home_dir'),
      user_base_dir             => '/home',
      user                      => hiera('oracle_db_os_user'),
      group                     => 'dba',
      group_install             => 'oinstall',
      group_oper                => 'oper',
      download_dir              => hiera('oracle_download_dir'),
      remote_file               => false,
      zip_extract               => true,
      puppet_download_mnt_point => hiera('oracle_source'),
    }

    oradb::net{ 'config net8':
      oracle_home  => hiera('oracle_home_dir'),
      version      => "12.1",
      user         => hiera('oracle_db_os_user'),
      group        => 'dba',
      download_dir => hiera('oracle_download_dir'),
      db_port      => '1521', 
      require      => Oradb::Installdb['db_linux-x64'],
    }

    db_listener{ 'startlistener':
      ensure          => 'running',  # running|start|abort|stop
      oracle_base_dir => hiera('oracle_base_dir'),
      oracle_home_dir => hiera('oracle_home_dir'),
      os_user         => hiera('oracle_db_os_user'),
      require         => Oradb::Net['config net8'],
    }

oradb::database{ 'oraDb':
      oracle_base               => hiera('oracle_base_dir'),
      oracle_home               => hiera('oracle_home_dir'),
      version                   => '12.1',
      user                      => hiera('oracle_db_os_user'),
      group                     => hiera('oracle_os_group'),
      download_dir              => hiera('oracle_download_dir'),
      action                    => 'create',
      db_name                   => hiera('oracle_database_name'),
      db_domain                 => hiera('oracle_database_domain_name'),
      sys_password              => hiera('oracle_database_sys_password'),
      system_password           => hiera('oracle_database_system_password'),
      template                  => 'dbtemplate_12.1',
      character_set             => 'WE8MSWIN1252',
      nationalcharacter_set     => 'UTF8',
      sample_schema             => 'TRUE',
      memory_percentage         => '60',
      memory_total              => '2048',
      database_type             => 'MULTIPURPOSE',
      em_configuration          => 'NONE',
      data_file_destination     => hiera('oracle_database_file_dest'),
      recovery_area_destination => hiera('oracle_database_recovery_dest'),
      init_params               => {'open_cursors'        => '1000',
                                    'processes'           => '600',
                                    'job_queue_processes' => '4' },
      container_database        => true,
      require                   => Db_listener['startlistener'],
    }
    oradb::dbactions{ 'start oraDb':
      oracle_home             => hiera('oracle_home_dir'),
      user                    => hiera('oracle_db_os_user'),
      group                   => hiera('oracle_os_group'),
      action                  => 'start',
      db_name                 => hiera('oracle_database_name'),
      require                 => Oradb::Database['oraDb'],
    }

    oradb::autostartdatabase{ 'autostart oracle':
      oracle_home             => hiera('oracle_home_dir'),
      user                    => hiera('oracle_db_os_user'),
      db_name                 => hiera('oracle_database_name'),
      require                 => Oradb::Dbactions['start oraDb'],
    }

    $oracle_database_file_dest = hiera('oracle_database_file_dest')
    $oracle_database_name = hiera('oracle_database_name')

    oradb::database_pluggable{'pdb1':
      ensure                   => 'present',
      version                  => '12.1',
      oracle_home_dir          => hiera('oracle_home_dir'),
      user                     => hiera('oracle_db_os_user'),
      group                    => 'dba',
      source_db                => hiera('oracle_database_name'),
      pdb_name                 => 'pdb1',
      pdb_admin_username       => 'pdb_adm',
      pdb_admin_password       => 'Welcome01',
      pdb_datafile_destination => "${oracle_database_file_dest}/${oracle_database_name}/pdb1",
      create_user_tablespace   => true,
      log_output               => true,
      require                  => Oradb::Autostartdatabase['autostart oracle'],
    }

    oradb::database_pluggable{'pdb2':
      ensure                   => 'present',
      version                  => '12.1',
      oracle_home_dir          => hiera('oracle_home_dir'),
      user                     => hiera('oracle_db_os_user'),
      group                    => 'dba',
      source_db                => hiera('oracle_database_name'),
      pdb_name                 => 'pdb2',
      pdb_admin_username       => 'pdb_adm',
      pdb_admin_password       => 'Welcome01',
      pdb_datafile_destination => "${oracle_database_file_dest}/${oracle_database_name}/pdb2",
      create_user_tablespace   => true,
      log_output               => true,
      require                  => Oradb::Database_pluggable['pdb1'],
    }
}
