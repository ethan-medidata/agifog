class Array
  def make_keys_restful    
    mappings = { "Description" => "description",
                 "State" => "state",
                 "InstanceId" => "id",
                 "ReasonCode" => "reason_code" }
    self.map do |instance_health| 
      Hash[instance_health.map {|k, v| [mappings[k] || k, v] }]
    end
  end
end