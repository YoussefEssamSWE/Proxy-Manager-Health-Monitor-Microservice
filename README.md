# Proxy Manager

A production-ready proxy management API built with Rails 7, MongoDB, and automated health monitoring.

## Features

- RESTful API for proxy management
- Automatic health checks with latency monitoring
- MongoDB for fast, scalable data storage
- Background scheduler for periodic health validation
- HTTP/HTTPS proxy support with fallback mechanism

## Tech Stack

- Ruby on Rails 7 (API mode)
- MongoDB with Mongoid ORM
- HTTParty for proxy testing
- Rufus Scheduler for background jobs
- Rack-CORS for API access

## Prerequisites

- Ruby 3.0+
- MongoDB 4.4+
- Bundler

## Installation

1. Install dependencies:
```bash
bundle install
```

2. Configure MongoDB connection in `config/mongoid.yml`

3. Start the server:
```bash
bundle exec rails server
```

The API will be available at `http://localhost:3000`

## API Endpoints

### Add Proxy
```bash
POST /api/v1/proxies
Content-Type: application/json

{
  "proxy": {
    "ip": "1.2.3.4",
    "port": 8080
  }
}
```

### List Proxies
```bash
GET /api/v1/proxies
GET /api/v1/proxies?status=healthy
```

### Get Best Proxy
```bash
GET /api/v1/proxy/best
```

### Trigger Health Check
```bash
POST /api/v1/proxy/check-all
```

## Health Monitoring

The system automatically tests each proxy every 10 minutes using a background scheduler. Health checks measure:

- Response time (latency in milliseconds)
- Connection status (healthy/dead)
- Last check timestamp

Proxies are tested against `httpbin.org/ip` with a 5-second timeout. The system tries HTTPS first and falls back to HTTP for better compatibility.

## Data Model

```ruby
{
  ip: String,              # Proxy IP address
  port: Integer,           # Port number (1-65535)
  status: String,          # 'healthy', 'dead', or 'unknown'
  latency: Float,          # Response time in ms
  last_checked_at: DateTime
}
```

## Configuration

- **Health check interval**: Edit `config/initializers/scheduler.rb`
- **Timeout duration**: Modify `TIMEOUT` in `app/services/proxy_health_check_service.rb`
- **CORS origins**: Configure in `config/initializers/cors.rb`
- **MongoDB settings**: Update `config/mongoid.yml`

## Project Structure

```
app/
├── controllers/api/v1/
│   └── proxies_controller.rb
├── models/
│   └── proxy.rb
└── services/
    └── proxy_health_check_service.rb
config/
├── initializers/
│   ├── mongoid.rb
│   ├── scheduler.rb
│   └── cors.rb
└── mongoid.yml
```

## Testing

Use the included test script:
```bash
./test_api.sh
```

## License

MIT
