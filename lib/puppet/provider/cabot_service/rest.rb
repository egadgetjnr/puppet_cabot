require File.join(File.dirname(__FILE__), '..', 'cabot_rest')

Puppet::Type.type(:cabot_service).provide :rest, :parent => Puppet::Provider::CabotRest do
  desc "REST provider for Cabot Service"
  
  mk_resource_methods

  def flush      
#    Puppet.debug "Cabot Service - Flush Started"
      
    if @property_flush[:ensure] == :absent
      deleteService
      return
    end
    
    if @property_flush[:ensure] == :present
      createService
      return
    end
    
    updateService
  end  

  def self.instances
    result = Array.new

    services = get_objects('services')
    if services != nil
      services.each do |service|
#        Puppet.debug "Service FOUND. ID = "+service["id"].to_s
        
        map = getService(service)
        if map != nil
#         Puppet.debug "Service Object: "+map.inspect
         result.push(new(map))
        end  
      end
    end
    
    result 
  end

  def self.getService(object)   
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
      
      instances = Array.new
      object["instances"].each do |instance|
        instances.push genericLookup('instances', 'id', instance, 'name')
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
        :url              => object["url"],          
        :instances        => instances,
        :ensure           => :present
      }
    end
  end
  
  # TYPE SPECIFIC        
  private
  def createService
    Puppet.debug "Create Service "+resource[:name]
      
    # 1. REST interface is not always available (prefetch can fail and Puppet < 4.0.0 ignores any exceptions)
    # 2. Cabot does not verify the name, does not enforce it is unique
    if !self.class.checkNameUnique('services', resource[:name])
      raise "Prefetch probably failed. Trying to create service #{resource[:name]}, but it already exists!"
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
    
    instances = Array.new
    resource[:instances].each do |instance|
      instances.push self.class.genericLookup('instances', 'name', instance, 'id')
    end     
      
    params = {         
      :name             => resource[:name],
      :users_to_notify  => users_to_notify,
      :alerts_enabled   => resource[:alerts_enabled],
      :status_checks    => status_checks,
      :alerts           => alerts,
      :hackpad_id       => resource[:hackpad_id],
      :url              => resource[:url],       
      :instances        => instances,
    }
    
#    Puppet.debug "POST services/ PARAMS = "+params.inspect
    response = self.class.http_post('services/', params) # Trailing / is important !!
  end

  def deleteService
    Puppet.debug "Delete Service "+resource[:name]
      
    id = self.class.genericLookup('services', 'name', resource[:name], 'id')
      
#    Puppet.debug "DELETE services/#{id}/"
    response = self.class.http_delete("services/#{id}/") # Trailing / is important !! 
  end
      
  def updateService
    Puppet.debug "Update Service "+resource[:name]
      
    id = self.class.genericLookup('services', 'name', resource[:name], 'id')
      
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
        
    if ! resource[:url].nil?
      params[:url] = resource[:url]
    end
      
    if ! resource[:instances].nil?
      instances = resource[:instances].collect do |user|
        self.class.genericLookup('instances', 'name', instance, 'id')
      end
      params[:instances] = instances
    end
    
#    Puppet.debug "PUT services/#{id}/ PARAMS = "+params.inspect
    response = self.class.http_put("services/#{id}/", params) # Trailing / is important !!
  end
end