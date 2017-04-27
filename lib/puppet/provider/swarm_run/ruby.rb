require 'socket'
require 'resolv'

Puppet::Type.type(:swarm_run).provide(:ruby) do
  desc "Support to run conatiners on your cluster"
  
  mk_resource_methods

  commands :docker => "docker"   
  
  def interface
    hostname = Socket.gethostname
    IPSocket.getaddress(hostname) 
  end
  
  def port
    ports = []  
    if (resource[:ports]).length > 0
      (resource[:ports]).each do |a|
        ports << a.to_s
      end
    end
    ports.flatten.each do |p| 
      if p.to_i > 0
        p.insert(0, '--publish=')
      else
       return []
      end
    end
  end

  def container_extra_parameter
     extra_parameters = (resource[:extra_parameter])
     extra_parameters.flatten.each do |p|
      if p.length == 0
         return []
      else
        x = p.insert(0, ' ')
        x.to_s
      end
    end
  end

  def container_env
     envs = (resource[:env])
     envs.flatten.each do |p| 
      if p.length == 0
         return []
      else
        x = p.insert(0, '-e ')
        x.to_s
      end
    end
  end

  def docker_run  
    name = (resource[:name])
    image = (resource[:image])
    volume = (resource[:volumes])
    volume_driver = (resource[:volume_driver])
    volumes_from = (resource[:volumes_from])
    network = (resource[:network])
    log_driver = (resource[:log_driver])
    log_opt = (resource[:log_opt])
    link = (resource[:link])
    label = (resource[:label])
    command = (resource[:command])
    ports = ''
      port.each do |pp|
      ports << pp + ' '
    end
    env = ''
    container_env.each do |c| 
      env << c + ' '
    end
    extra_parameter = ''
    container_extra_parameter.each do |c|
      extra_parameter << c + ' '
    end
    run = ['-H', "tcp://#{interface}:2376", 'run', '-v', "#{volume}", '--volume-driver=', "#{volume_driver}",
         '--volumes-from=', "#{volumes_from}", '--link', "#{link}", '--log-driver=', "#{log_driver}", '--log-opt=', "#{log_opt}", 
         '--label=', "#{label}", env, extra_parameter, '--net=', "#{network}", ports, '-d', '--name', "#{name}", "#{image}", "#{command}",]

    if volume.to_s.strip.length == 0 then run.delete("-v")
      end 
    if volume_driver.to_s.strip.length == 0 then run.delete("--volume-driver=")
      end
    if volumes_from.to_s.strip.length == 0 then run.delete("--volumes-from=")
      end           
    if link.to_s.strip.length == 0 then run.delete("--link")
      end
    if log_driver.to_s.strip.length == 0 then run.delete("--log-driver=")
      end             
    if log_opt.to_s.strip.length == 0 then run.delete("--log-opt=")
      end             
    if network.to_s.strip.length == 0 then run.delete("--net=")
      end             
    if label.to_s.strip.length == 0 then run.delete("--label=")
      end             
    if container_env.to_s.strip.length == 0 then run.delete("-e")
      end 
    if container_extra_parameter.to_s.strip.length == 0 then run.delete("-e")
      end
    run.reject { |item| item.nil? || item == '' } 
    str = ''
    run.each do |m|
      str << m.to_s + ' ' 
    end
    s = str.gsub('= ', '=')
    t =  s.gsub(/\s+/, ' ')
    t.rstrip.split
  end
   
  def deps
    if (resource[:depends]).empty?
      return Puppet.info("container #{resource[:name]} has no dependencies")
    else  
      begin
        args = ['-H', "tcp://#{interface}:2376", 'inspect', '-f', '{{.State.Running}}', "#{resource[:depends]}"]
        docker *args
      rescue => e
        retry 
       end
     end
   end 
  
  def exists?
    Puppet.info("checking if container #{resource[:name]} is running")
      begin
        args = ['-H', "tcp://#{interface}:2376", 'inspect', '-f', '{{.State.Running}}', "#{resource[:name]}"]
        docker *args
      rescue => e
        return false
      else
        return true   
      end 
   end
 
   def create
     Puppet.info("running container #{resource[:name]} on swarm cluster")
       deps
       p = fork {docker *docker_run}
       Process.detach(p)      
   end

   def destroy
     Puppet.info("stopping container #{resource[:name]}")
     args = ['-H', "tcp://#{interface}:2376", 'rm', '-f', "#{resource[:name]}"]
     docker *args
   end
 end
