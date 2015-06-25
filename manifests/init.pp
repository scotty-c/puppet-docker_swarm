
# A module for Docker swarm 

class swarm(

  $install_docker  = $swarm::params::install_docker,
  $install_golang  = $swarm::params::install_golang,
  $go_version      = $swarm::params::version,
  $bind            = $swarm::params::bind,
  $swarmroot       = $swarm::params::swarmroot,
  $base_dir        = $swarm::params::base_dir,
  $swarm_dir       = $swarm::params::swarm_dir,
  $swarm_version   = $swarm::params::swarm_version,

) inherits swarm::params {
  validate_re($::osfamily, '^(Debian|RedHat)$', 'This module only works on Debian and Red Hat based systems.')
  validate_bool($install_docker)
  validate_bool($install_golang)

  if ! defined(Package['git']) {
    package { 'git':
      ensure => installed,
      before => Class['golang']
    }
  }

  if install_docker {
    class {'docker':
      tcp_bind       => $bind,
      }
    
    Class['docker'] -> Class['swarm::install']
  }
  
  if install_golang {
    class {'golang':
      version => $go_version,
      }
    Class['golang'] -> Class['swarm::install']
  }

  class {'swarm::install':}
}

