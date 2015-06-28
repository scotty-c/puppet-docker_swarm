
# A module for Docker swarm 

class docker_swarm(

  $install_docker  = $docker_swarm::params::install_docker,
  $install_golang  = $docker_swarm::params::install_golang,
  $go_version      = $docker_swarm::params::version,
  $bind            = $docker_swarm::params::bind,
  $swarmroot       = $docker_swarm::params::swarmroot,
  $base_dir        = $docker_swarm::params::base_dir,
  $swarm_dir       = $docker_swarm::params::swarm_dir,
  $swarm_version   = $docker_swarm::params::swarm_version,

) inherits docker_swarm::params {
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
    
    Class['docker'] -> Class['docker_swarm::install']
  }
  
  if install_golang {
    class {'golang':
      version => $go_version,
      }
    Class['golang'] -> Class['docker_swarm::install']
  }

  class {'docker_swarm::install':}
}

