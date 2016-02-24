Puppet::Type.newtype(:rest_resource) do
  desc "Puppet type for interfacing with an HTTP API"

  ensurable

  newparam(:name, :namevar => true) do
    desc "Name of the resource"
  end

  newparam(:base_url) do
    desc "Base URL of the API"
  end

  newparam(:auth_type) do
    desc "What type of authentication this API uses"
    defaultto "none"
    validate do |value|
      if not ['none', 'basic'].include? value
        raise Puppet::Error, "Type rest_resource: auth_type should be one of basic, none"
      end
    end
  end

  newparam(:identity) do
    desc "The API identifier, usually a username"
  end

  newparam(:secret) do
    desc "The API secret, usually a password or API key"
  end

  newparam(:verify_ssl) do
    desc "Whether to verify SSL when connecting to the API"
    defaultto true
  end

  newparam(:exists, :array_matching => :all) do
    desc "A hash describing how to determine if this resource exists"
  end

  newparam(:create, :array_matching => :all) do
    desc "A hash describing how to create a resource"
  end

  validate do
    ["exists", "create"].each { |param|
      value = self[param]
      if not value.is_a?(Hash)
        raise Puppet::Error, "Type rest_resource: #{param} must be a hash"
      end
      if not value.has_key?("endpoint")
        raise Puppet::Error, "Type rest_resource: you must define an endpoint for #{param}"
      end
    }  
  end

end
