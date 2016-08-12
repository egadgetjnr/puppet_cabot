require File.join(File.dirname(__FILE__), '..', 'cabot_rest')

Puppet::Type.type(:cabot_instance).provide :rest, :parent => Puppet::Provider::CabotRest do
  desc "REST provider for Cabot Instance"
  
  mk_resource_methods

  def flush      
#    Puppet.debug "Cabot Instance - Flush Started"
      
    if @property_flush[:ensure] == :absent
      deleteInstance
      return
    end
    
    if @property_flush[:ensure] == :present
      createInstance
      return
    end
    
    updateInstance
  end  

  def self.instances
    result = Array.new

    instances = get_objects('instances')    
    if instances != nil
      instances.each do |instance|
#        Puppet.debug "Instance FOUND. ID = "+instance["id"].to_s
        
        map = getInstance(instance)
        if map != nil
#         Puppet.debug "Instance Object: "+map.inspect
         result.push(new(map))
        end  
      end
    end
    
    result 
  end

  def self.getInstance(object)   
    if object["id"] != nil   
      users_to_notify = Array.new
      object["users_to_notify"].each do |user|
        users_to_notify.push userLookupById(user)
      end
      
      status_checks = Array.new
      object["status_checks"].each do |status_check|
        status_checks.push genericLookup('status_checks', 'id', status_check, 'name')
      end
      
      alerts = Array.new
      object["alerts"].each do |alert|
        alerts.push genericLookup('alertplugins', 'id', alert, 'title')
      end      
      
      alerts_enabled = case 
      when object["alerts_enabled"]
        :true
      else
        :false
      end
      
      {
        :id               => object["id"],
        :name             => object["name"],          
        :users            => users_to_notify,
        :alerts_enabled   => alerts_enabled,
        :status_checks    => status_checks,
        :alerts           => alerts,
        :hackpad_id       => object["hackpad_id"],
        :address          => object["address"],          
        :ensure           => :present
      }
    end
  end
  
  # TYPE SPECIFIC        
  private
  def createInstance
    Puppet.debug "Create Instance "+resource[:name]

    # 1. REST interface is not always available (prefetch can fail and Puppet < 4.0.0 ignores any exceptions)
    # 2. Cabot does not verify the name, does not enforce it is unique
    if !self.class.checkNameUnique('instances', resource[:name])
      raise "Prefetch probably failed. Trying to create instance #{resource[:name]}, but it already exists!"
    end

    users_to_notify = Array.new
    resource[:users].each do |user|
      users_to_notify.push self.class.userLookupByName(user)
    end
    
    status_checks = Array.new
    resource[:status_checks].each do |status_check|
      status_checks.push self.class.genericLookup('status_checks', 'name', status_check, 'id')
    end
    
    alerts = Array.new
    resource[:alerts].each do |alert|
      alerts.push self.class.genericLookup('alertplugins', 'title', alert, 'id')
    end
      
    params = {         
      :name             => resource[:name],
      :users_to_notify  => users_to_notify,
      :alerts_enabled   => resource[:alerts_enabled],
      :status_checks    => status_checks,
      :alerts           => alerts,
      :hackpad_id       => resource[:hackpad_id],
      :address          => resource[:address],
    }
    
#    Puppet.debug "POST instances PARAMS = "+params.inspect
    response = self.class.http_post('instances/', params) # Trailing / is important !!
  end

  def deleteInstance
    Puppet.debug "Delete Instance "+resource[:name]
      
    id = self.class.genericLookup('instances', 'name', resource[:name], 'id')
      
#    Puppet.debug "DELETE instances/#{id}/"
    response = self.class.http_delete("instances/#{id}/") # Trailing / is important !! 
  end
      
  def updateInstance
    Puppet.debug "Update Instance "+resource[:name]
      
    id = self.class.genericLookup('instances', 'name', resource[:name], 'id')
      
    params = {         
      :name => resource[:name],
    }
      
    if ! resource[:users].nil?
      users_to_notify = resource[:users].collect do |user|
        self.class.userLookupByName(user)
      end
      params[:users_to_notify] = users_to_notify
    end
      
    if ! resource[:alerts_enabled].nil?
      params[:alerts_enabled] = resource[:alerts_enabled]
    end

    if ! resource[:status_checks].nil?
      status_checks = resource[:status_checks].collect do |user|
        self.class.genericLookup('status_checks', 'name', status_check, 'id')
      end
      params[:users_to_notify] = status_checks
    end

    if ! resource[:alerts].nil?
      alerts = resource[:alerts].collect do |user|
        self.class.genericLookup('alertplugins', 'title', alert, 'id')
      end
      params[:users_to_notify] = alerts
    end
    
    if ! resource[:hackpad_id].nil?
      params[:hackpad_id] = resource[:hackpad_id]
    end
        
    if ! resource[:address].nil?
      params[:address] = resource[:address]
    end
          
#    Puppet.debug "PUT instances/#{id}/ PARAMS = "+params.inspect
    response = self.class.http_put("instances/#{id}/", params) # Trailing / is important !!
  end
end