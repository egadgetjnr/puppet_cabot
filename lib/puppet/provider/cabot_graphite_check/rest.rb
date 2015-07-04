require File.join(File.dirname(__FILE__), '..', 'cabot_rest')

Puppet::Type.type(:cabot_graphite_check).provide :rest, :parent => Puppet::Provider::Rest do
  desc "REST provider for Cabot Graphite Check"

  mk_resource_methods

  def flush      
#    Puppet.debug "Cabot Graphite Check - Flush Started"
      
    if @property_flush[:ensure] == :absent
      deleteCheck
      return
    end
    
    if @property_flush[:ensure] == :present
      createCheck
      return
    end
    
    updateCheck
  end  

  def self.instances
    result = Array.new
        
    checks = get_objects('graphite_checks')
    if checks != nil
      checks.each do |check|
#        Puppet.debug "Graphite Check FOUND. ID = "+check["id"].to_s
        
        map = getCheck(check)
        if map != nil
#         Puppet.debug "Graphite Check Object: "+map.inspect
         result.push(new(map))
        end  
      end
    end
    
    result 
  end

  def self.getCheck(object)   
    if object["id"] != nil   
      {
        :id                   => object["id"],
        :name                 => object["name"],
        :active               => object["active"],
        :importance           => object["importance"],
        :frequency            => object["frequency"].to_s,
        :debounce             => object["debounce"].to_s,
        :metric               => object["metric"],
        :check_type           => object["check_type"],
        :value                => object["value"],
        :expected_num_hosts   => object["expected_num_hosts"].to_s,
        :expected_num_metrics => object["expected_num_metrics"].to_s,
        :ensure               => :present
      }
    end
  end
  
  # TYPE SPECIFIC        
  private
  def createCheck
#    Puppet.debug "Create Graphite Check "+resource[:name]

    params = {
      :name                 => resource[:name],
      :active               => resource[:active],
      :importance           => resource[:importance],
      :frequency            => resource[:frequency],
      :debounce             => resource[:debounce],
      :metric               => resource[:metric],
      :check_type           => resource[:check_type],
      :value                => resource[:value],
      :expected_num_hosts   => resource[:expected_num_hosts],
      :expected_num_metrics => resource[:expected_num_metrics],
    }
    
#    Puppet.debug "POST graphite_checks/ PARAMS = "+params.inspect
    response = self.class.http_post('graphite_checks/', params) # Trailing / is important !!
  end

  def deleteCheck
#    Puppet.debug "Delete Graphite Check "+resource[:name]

    id = self.class.genericLookup('graphite_checks', 'name', resource[:name], 'id')
      
#    Puppet.debug "DELETE graphite_checks/#{id}/"
    response = self.class.http_delete("graphite_checks/#{id}/") # Trailing / is important !! 
  end
      
  def updateCheck
#    Puppet.debug "Update Graphite Check "+resource[:name]
      
    id = self.class.genericLookup('graphite_checks', 'name', resource[:name], 'id')
      
    params = {
      :name                 => resource[:name],
      :active               => resource[:active],
      :importance           => resource[:importance],
      :frequency            => resource[:frequency],
      :debounce             => resource[:debounce],
      :metric               => resource[:metric],
      :check_type           => resource[:check_type],
      :value                => resource[:value],
      :expected_num_hosts   => resource[:expected_num_hosts],
      :expected_num_metrics => resource[:expected_num_metrics],
    }
 
#    Puppet.debug "PUT graphite_checks/#{id}/ PARAMS = "+params.inspect
    response = self.class.http_put("graphite_checks/#{id}/", params) # Trailing / is important !!
  end
end