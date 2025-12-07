class ProxyHealthCheckService
  include HTTParty

  TEST_URL = 'https://httpbin.org/ip'
  TIMEOUT = 5

  def self.check_proxy(proxy)
    new(proxy).check
  end

  def self.check_all_proxies
    Proxy.all.each do |proxy|
      check_proxy(proxy)
    end
  end

  def initialize(proxy)
    @proxy = proxy
  end

  def check
    start_time = Time.now
    
    begin
      # First try HTTPS
      response = HTTParty.get(
        TEST_URL,
        timeout: TIMEOUT,
        http_proxyaddr: @proxy.ip,
        http_proxyport: @proxy.port
      )

      if response.success?
        latency = ((Time.now - start_time) * 1000).round(2) # Convert to milliseconds
        @proxy.mark_as_healthy!(latency)
        
        Rails.logger.info "✓ Proxy #{@proxy.proxy_url} is HEALTHY (#{latency}ms)"
        return { success: true, latency: latency, status: 'healthy' }
      else
        @proxy.mark_as_dead!
        Rails.logger.warn "✗ Proxy #{@proxy.proxy_url} returned status #{response.code}"
        return { success: false, status: 'dead', error: "HTTP #{response.code}" }
      end
    rescue Net::OpenTimeout, Net::ReadTimeout => e
      # HTTPS failed, try HTTP endpoint for free proxies
      Rails.logger.info "HTTPS timeout for #{@proxy.proxy_url}, trying HTTP..."
      
      begin
        start_time = Time.now
        response = HTTParty.get(
          'http://httpbin.org/ip',
          timeout: TIMEOUT,
          http_proxyaddr: @proxy.ip,
          http_proxyport: @proxy.port
        )

        if response.success?
          latency = ((Time.now - start_time) * 1000).round(2)
          @proxy.mark_as_healthy!(latency)
          Rails.logger.info "✓ Proxy #{@proxy.proxy_url} is HEALTHY via HTTP (#{latency}ms)"
          return { success: true, latency: latency, status: 'healthy', method: 'http' }
        else
          @proxy.mark_as_dead!
          Rails.logger.warn "✗ Proxy #{@proxy.proxy_url} HTTP also failed: #{response.code}"
          return { success: false, status: 'dead', error: "HTTP #{response.code}" }
        end
      rescue StandardError => http_error
        @proxy.mark_as_dead!
        Rails.logger.warn "✗ Proxy #{@proxy.proxy_url} HTTP error: #{http_error.message}"
        return { success: false, status: 'dead', error: http_error.message }
      end
    rescue StandardError => e
      @proxy.mark_as_dead!
      Rails.logger.error "✗ Proxy #{@proxy.proxy_url} ERROR: #{e.class} - #{e.message}"
      { success: false, status: 'dead', error: e.message }
    end
  end
end
