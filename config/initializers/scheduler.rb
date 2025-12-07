require 'rufus-scheduler'

scheduler = Rufus::Scheduler.new

scheduler.every '10m', first_in: '30s' do
  Rails.logger.info 'Running scheduled proxy health check'
  
  start_time = Time.now
  total_proxies = Proxy.count
  
  next if total_proxies.zero?

  ProxyHealthCheckService.check_all_proxies
  
  duration = (Time.now - start_time).round(2)
  healthy_count = Proxy.healthy.count
  dead_count = Proxy.dead.count
  
  Rails.logger.info "Health check completed in #{duration}s - #{healthy_count} healthy, #{dead_count} dead"
end
