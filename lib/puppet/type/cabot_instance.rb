# Custom Type: Cabot - Instance

Puppet::Type.newtype(:cabot_instance) do
  @doc = "Cabot Instance"
  
  ensurable
  
  newparam(:name, :namevar => true) do
    desc "The instance name"
  end

  newproperty(:users, :array_matching => :all) do    # users_to_notify
    desc "List of users to notify"
  end

  newproperty(:alerts_enabled) do
    desc "Whether to enable alerts for this instance"
  end 
  
  newproperty(:status_checks, :array_matching => :all) do
    desc "List of status checks to enable for this instance"
  end
  
  newproperty(:alerts, :array_matching => :all) do
    desc "List of alert methods to enable"
  end
  
#  newproperty(:hackpad_id) do
#    desc "A URL for more information on how to resolve the issue?"
#  end
  
  newproperty(:address) do
    desc "The instance IP/Hostname"
  end
end