class Proxy
  include Mongoid::Document
  include Mongoid::Timestamps

  field :ip, type: String
  field :port, type: Integer
  field :status, type: String, default: 'unknown'
  field :latency, type: Float
  field :last_checked_at, type: DateTime

  validates :ip, presence: true, format: { 
    with: /\A(?:[0-9]{1,3}\.){3}[0-9]{1,3}\z/,
    message: 'must be a valid IP address'
  }
  validates :port, presence: true, 
    numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 65535 }
  validates :status, inclusion: { in: %w[healthy dead unknown] }

  index({ status: 1 })
  index({ latency: 1 })
  index({ last_checked_at: 1 })
  index({ ip: 1, port: 1 }, { unique: true })

  scope :healthy, -> { where(status: 'healthy') }
  scope :dead, -> { where(status: 'dead') }
  scope :by_latency, -> { order(latency: :asc) }

  def self.best_available
    healthy.by_latency.first
  end

  def proxy_url
    "http://#{ip}:#{port}"
  end

  def mark_as_healthy!(latency_ms)
    update!(status: 'healthy', latency: latency_ms, last_checked_at: Time.now)
  end

  def mark_as_dead!
    update!(status: 'dead', latency: nil, last_checked_at: Time.now)
  end
end
