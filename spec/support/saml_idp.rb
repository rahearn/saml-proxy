SamlIdp.configure do |config|
  config.service_provider.finder = ->(_) do
    {
      response_hosts: ["localhost"]
    }
  end
end
