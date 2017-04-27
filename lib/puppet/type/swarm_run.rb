Puppet::Type.newtype(:swarm_run) do
    @doc = "Runs Docker Swarm"

    ensurable do
      defaultvalues
      defaultto :present
    end

    newparam(:name, :namevar => true) do
      desc "Application name"  
    end
    
    newproperty(:ports, :array_matching => :all) do 
      desc "Ports for guest and host. An example would look like 80:80"
      defaultto '0'
      def insync?(is)
        if is.is_a?(Array) and @should.is_a?(Array)
           is.sort == @should.sort
       else
          is == @should
        end
      end
    end

    newparam(:image) do
      desc "Docker image to pull"
    end
    
    newparam(:volumes) do
      desc "Bind mount a volume"
    end
    
    newparam(:volume_driver) do
      desc "Optional volume driver for the container"
    end

    newparam(:volumes_from) do
      desc "Mount volumes from the specified container(s)"
    end 

    newparam(:network) do
      desc "Set the Network for the container"
    end

    newparam(:log_driver) do
      desc "Logging driver for container"
    end
    
    newparam(:log_opt) do
      desc "Log driver options"
    end

    newparam(:link) do
      desc "Add link to another container"
    end
    
    newparam(:label) do
      desc "Set meta data on a container"
    end
    
    newproperty(:extra_parameter, :array_matching => :all) do
      desc "Set extra parameters for the container"
      defaultto ''
       def insync?(is)
        if is.is_a?(Array) and @should.is_a?(Array)
           is.sort == @should.sort
       else
          is == @should
        end
      end
    end

    newproperty(:env, :array_matching => :all) do
      desc "Set the environment variables for the conatiner"
      defaultto ''
       def insync?(is)
        if is.is_a?(Array) and @should.is_a?(Array)
           is.sort == @should.sort
       else
          is == @should
        end
      end
    end
    
    newparam(:depends) do
      desc "Name of service that the current service depends on"
      defaultto ''
    end

    newparam(:command) do
      desc "Pass an argument to container"
      defaultto ""
    end
end
