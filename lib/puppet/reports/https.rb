require 'puppet'
require 'uri'

Puppet::Reports.register_report(:https) do

  desc <<-DESC
    Send reports via HTTPS. This report processor submits reports as
    POST requests to the address in the `reporturl` setting. The body of each POST
    request is the YAML dump of a Puppet::Transaction::Report object, and the
    Content-Type is set as `application/x-yaml`.
  DESC

  def process
    url = URI.parse(Puppet[:reporturl])
    body = self.to_yaml
    headers = { "Content-Type" => "application/x-yaml" }
    use_ssl = true
    conn = Net::HTTP.new(url.host, url.port)
    conn.use_ssl = true
    conn.cert_store = OpenSSL::X509::Store.new
    conn.cert_store.set_default_paths
    conn.verify_mode = OpenSSL::SSL::VERIFY_PEER
    response = conn.post(url.path, body, headers)
    unless response.kind_of?(Net::HTTPSuccess)
      Puppet.err "Unable to submit report to #{Puppet[:reporturl].to_s} [#{response.code}] #{response.msg}"
    end
  end
end 
