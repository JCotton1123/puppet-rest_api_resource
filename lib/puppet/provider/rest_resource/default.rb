require 'net/http'
require 'json'

Puppet::Type.type(:rest_resource).provide(:default) do

  def exists?
    exists, msg = ensure_resource(@resource['exists'])
    debug(msg) if not msg.empty?
    return exists
  end

  def create
    created, msg = ensure_resource(@resource['create'])
    if not created
      raise Puppet::Error, msg
    end
  end

  def destroy
    raise Puppet::Error, "Destroying a resource is not currently supported"
  end

  def ensure_resource(params)
    default_params = {
      'method' => 'GET',
      'status' => '200'
    }
    params = default_params.merge(params)
    uri = URI(@resource['base_url'] + params['endpoint'])
    client = Net::HTTP.new(uri.host, uri.port)
    client.use_ssl = uri.scheme == "https"
    if not @resource['verify_ssl']
      client.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    request = nil
    if params['method'] == 'GET'
      request = Net::HTTP::Get.new(uri.request_uri)
    elsif params['method'] == 'POST'
      request = Net::HTTP::Post.new(uri.request_uri)
      if params.has_key?('body')
        request.body = params['body'].to_json
      end
      request.content_type = "application/json"
    else
      raise ArgumentError, "Unsupported method #{params['method']}"
    end
    if @resource['auth_type'] == 'basic'
      request.basic_auth(@resource['identity'], @resource['secret'])
    end
    debug("requesting " + uri.to_s)
    response = client.request(request)
    return parse_response(response, params)
  end

  def parse_response(response, params)
    code = response.code
    body = response.body
    debug("response code = #{code}")
    debug("response body = #{body}")
    if params.has_key?('status') and code != params['status']
      return false, "Returned status code #{code} does not match expected code #{params['status']}"
    end
    if params.has_key?('regex')
      reg = Regexp.new(params['regex'])
      if reg.match(body) == nil
        return false, "Response body did not contain a match for #{params['regex']}"
      end
    end
    return true, ""
  end

  def debug(msg)
    Puppet.debug("rest_resource: #{msg}")
  end

end
