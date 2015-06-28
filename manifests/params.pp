class docker_swarm::params {

  $install_docker   = true
  $install_golang   = true
  $go_version       = 'go1.4.2'
  $bind             = 'tcp://0.0.0.0:2375'
  $swarmroot        = '$GOPATH/bin:/usr/local/go/bin:$PATH'
  $base_dir         = '/usr/local/go/src/github.com'
  $swarm_dir        = '/usr/local/go/src/github.com/docker/swarm'
  $swarm_version    = undef
}