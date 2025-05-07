Faraday.default_adapter = :typhoeus

class Net::HTTP
  # monkey patch .get to avoid Net::HTTP.get not playing nicely with egress proxying
  def self.get(uri_or_host, path_or_headers = nil, port = nil)
    if (path_or_headers.present? && !path_or_headers.is_a?(Hash)) || port.present?
      fail "Net::HTTP.get does not work properly with cg-egress-proxy. Update code to use Faraday with typhoeus"
    end
    Faraday.get(uri_or_host, nil, path_or_headers).body
  end
end
