# The private class that looks after the swarm install

class swarm::install {


file { [$swarm::base_dir, $swarm::base_dir/docker]:
  ensure  => directory,
  recurse => true,
  } ->

vcsrepo { $swarm::swarm_dir:
  ensure   => present,
  provider => git,
  source   => 'https://github.com/docker/swarm.git',
  revision => $swarm::swarm_version,
  require  => File[$swarm::base_dir]
  } ->

exec { 'build swarm':
  cwd       => '/usr/local/go/src/github.com/docker/swarm',
  command   => "bash -l -c 'go get github.com/tools/godep && godep go install . && source /etc/profile'",
  path      => '/usr/local/go/bin/:/usr/bin:/bin:',
  creates   => '/usr/local/go/bin/swarm',
  timeout   => 600 , #This is for slower machines or vagrant testing
  logoutput => on_failure,
  }

file { 'symlink swarm':
  ensure  => link,
  path    => '/usr/bin/swarm',
  target  => '/usr/local/go/bin/swarm',
  require => Exec['build swarm']
  }
}