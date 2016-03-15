require 'socket'
require 'resolv'

Puppet::Type.type(:swarm_cluster).provide(:ruby) do
  desc "Support for Docker Swarm"
  
  mk_resource_methods

  commands :swarm => "swarm"
  commands :ps => "ps"
  commands :pidof => "pidof"   

  def interface
    hostname = Socket.gethostname
    IPSocket.getaddress(hostname) 
  end

  def swarm_conf
    cluster = resource[:cluster_type] 
    backend = (resource[:backend])
    address = (resource[:address])
    port = (resource[:port])  
    advertise = (resource[:advertise])  
    path = (resource[:path])
    case 
      when cluster.match(/create/)
        [['create']]
      when cluster.match(/join/)
        [['--experimental', 'join', "--advertise=#{interface}:2375", "#{backend}://#{address}:#{port}/#{path}"]]
      when cluster.match(/manage/)      
        [['--experimental', 'manage', '-H', "tcp://#{interface}:2376", "#{backend}://#{address}:#{port}/#{path}"], ['--experimental', 'manage', '-H', ':4000', '--replication', '--advertise', "#{advertise}:4000", "#{backend}://#{address}:#{port}/#{path}"]] 
      end
   end

   def exists?
      Puppet.info("checking if the swarm is running")
      args = ['-ef']
      pid = ps *args  
      pid.match('swarm')
   end
 
   def create
     Puppet.info("configuring the swarm cluster")
     swarm_conf.each do |conf|
       p = fork {swarm *conf}
       Process.detach(p)
     end
   end

   def destroy
     Puppet.info("stoping swarm process")
     system "pidof swarm | xargs kill -9 $1"
   end
end
