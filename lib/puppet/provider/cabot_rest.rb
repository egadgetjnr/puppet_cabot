begin
  require 'rest-client' if Puppet.features.rest_client?
  require 'json' if Puppet.features.json?
  require 'yaml/store' # TODO  
rescue LoadError => e
  Puppet.info "Cabot Puppet module requires 'rest-client' and 'json' ruby gems."
end

class Puppet::Provider::Rest < Puppet::Provider
  desc "Cabot API REST calls"
  
  confine :feature => :json
  confine :feature => :rest_client
  
  def initialize(value={})
    super(value)
    @property_flush = {} 
  end
    
  def self.get_rest_info
    config_file = "/etc/puppet/cabot_api.yaml"
    
    data = File.read(config_file) or raise "Could not read setting file #{config_file}"    
    yamldata = YAML.load(data)
        
    if yamldata.include?('ip')
      ip = yamldata['ip']
    else
      ip = 'localhost'
    end

    if yamldata.include?('port')
      port = yamldata['port']
    else
      port = '80'
    end

    if yamldata.include?('username')
      username = yamldata['username']
    else
      raise "The configuration file #{config_file} should include username!"
    end

    if yamldata.include?('password')
      password = yamldata['password']
    else
      raise "The configuration file #{config_file} should include password!"
    end

    if yamldata.include?('users')
      users = yamldata['users']
    else
      raise "The configuration file #{config_file} should include 'users' hash (id => username)!"
    end
      
    result = { 
      :ip       => ip, 
      :port     => port,
      :username => username,
      :password => password,
      :users    => users,
    }
    
    result
  end
  
  def self.userLookupByName(name)
    rest = get_rest_info    
    rest[:users].key(name)
  end
  
  def self.userLookupById(id)
    rest = get_rest_info    
    rest[:users][id]
  end        

  def exists?    
    @property_hash[:ensure] == :present
  end
  
  def create
    @property_flush[:ensure] = :present
  end

  def destroy        
    @property_flush[:ensure] = :absent
  end
          
  def self.prefetch(resources)        
    instances.each do |prov|
      if resource = resources[prov.name]
       resource.provider = prov
      end
    end
  end  
   
  def self.get_objects(endpoint, resultName = nil)    
#    Puppet.debug "CABOT-API (generic) get_objects: #{endpoint}"
    
    response = http_get(endpoint)
      
#    Puppet.debug("Call to #{endpoint} on CABOT API returned #{response}")

    if resultName == nil
      response      
    else 
      response[resultName]      
    end
  end
  
  def self.http_get(endpoint) 
    http_generic('GET', endpoint)
  end

  def self.http_post(endpoint, data = {}) 
    http_generic('POST', endpoint, data.to_json)
  end
  
  def self.http_put(endpoint, data = {}) 
    http_generic('PUT', endpoint, data.to_json)
  end
  
  def self.http_delete(endpoint) 
    http_generic('DELETE', endpoint, {}, false)
  end
  
  def self.http_generic(method, endpoint, data = {}, jsonResult = true) 
    #Puppet.debug "CABOT-API (http_generic) #{method}: #{endpoint}"
    
    resource = createResource(endpoint)
        
    begin
      case method
      when 'GET'
        response = resource.get         
      when 'POST'        
        response = resource.post data, :content_type => :json
      when 'PUT'
        response = resource.put data, :content_type => :json
      when 'DELETE'
        response = resource.delete 
      else
        raise "CABOT-API - Invalid Method: #{method}"
      end
    rescue => e
      Puppet.debug "CABOT API response: "+e.inspect
      raise "Unable to contact CABOT API on #{resource.url}: #{e.response}"
    end
  
    if jsonResult 
      begin
        responseJson = JSON.parse(response)
      rescue
        raise "Could not parse the JSON response from CABOT API: #{response}"
      end
    else
      responseJson = response
    end
    
    responseJson
  end
    
  def self.createResource(endpoint)
    rest = get_rest_info
    #Puppet.debug "CABOT-API REST INFO: #{rest.inspect}"
    
    url = "http://#{rest[:ip]}:#{rest[:port]}/api/#{endpoint}"
    
    resource = RestClient::Resource.new(url, :user => rest[:username], :password => rest[:password])
    
    resource
  end
  
  def self.genericLookup(endpoint, lookupVar, lookupVal, returnVar)
    list = get_objects(endpoint)
           
    if list != nil
      list.each do |object|
        if object[lookupVar] == lookupVal
          return object[returnVar]
        end        
      end
    end
  
    raise "Could not find "+endpoint+" where "+lookupVar+" = "+lookupVal.to_s
  end  
end