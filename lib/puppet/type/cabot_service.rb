# Custom Type: Cabot - Service

Puppet::Type.newtype(:cabot_service) do
  @doc = "Cabot Service"
  
  ensurable
  
  newparam(:name, :namevar => true) do
    desc "The service name"
  end

  newproperty(:users, :array_matching => :all) do    # users_to_notify
    desc "List of users to notify"
  end

  newproperty(:alerts_enabled) do
    desc "Whether to enable alerts for this service"
    newvalues(:true, :false)
    defaultto :true
  end 
  
  newproperty(:status_checks, :array_matching => :all) do
    desc "List of status checks to enable for this service"
  end
  
  newproperty(:alerts, :array_matching => :all) do
    desc "List of alert methods to enable"
  end
  
  newproperty(:hackpad_id) do
    desc "A URL for more information on how to resolve the issue"
  end
  
  newproperty(:url) do
    desc "The service URL"
  end
  
  newproperty(:instances, :array_matching => :all) do
    desc "List of instances that the service applies to"
  end
end