# Custom Type: Cabot - Graphite Check

Puppet::Type.newtype(:cabot_graphite_check) do
  @doc = "Cabot Graphite Check"
  
  ensurable
  
  newparam(:name, :namevar => true) do
    desc "The check name"
  end

  newproperty(:active) do
    desc "Whether the check is active"
    defaultto true
  end

  newproperty(:importance) do
    desc "The importance level of the check: WARNING|ERROR|CRITICAL"
    newvalues(:WARNING, :ERROR, :CRITICAL)
  end 
  
  newproperty(:frequency) do
    desc "Minutes between each check"
    defaultto 5
  end
  
  newproperty(:debounce) do
    desc "Number of successive times to check can fail before alerting"
  end
    
  newproperty(:metric) do
    desc "Graphite Expression"
  end
  
  newproperty(:check_type) do
    desc "Comparison Operator: <, <=, ==, >, >="
    newvalues("<", "<=", "==", ">", ">=")
  end
  
  newproperty(:value) do
    desc "The threshold value"
  end
  
  newproperty(:expected_num_hosts) do
    desc "Minimum number of hosts (data series) expected"
  end
  
  newproperty(:expected_num_metrics) do
    desc "Minimum number of metrics expected to satisfy the condition"
  end
end