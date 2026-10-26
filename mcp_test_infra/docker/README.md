# Docker Local Infrastructure Environment

This directory contains Docker configuration for local infrastructure testing and development. This provides a containerized environment that mirrors the AWS cloud infrastructure deployed via Terraform.

**Application Note:** The application code is maintained in the separate `mcp_cli_test_app` repository. To run the full stack locally, mount the application code from that repository into the container or build the application container separately.

## Quick Start

1. **Start the infrastructure environment:**
   ```bash
   cd docker
   docker-compose up -d
   ```

2. **Access infrastructure services:**
   - **Application Port:** 5000 (ready for application container)
   - **Database Admin (pgAdmin):** http://localhost:8080
   - **Redis Admin:** http://localhost:8081
   - **PostgreSQL:** localhost:5432
   - **Redis:** localhost:6379

3. **Stop the environment:**
   ```bash
   docker-compose down
   ```

## Infrastructure Services

### Application Container (`badger-app`)
- **Port:** 5000
- **Purpose:** Placeholder container for application deployment testing
- **Configuration:** Environment variables match AWS ECS task definition
- **Note:** Mount application code from `mcp_cli_test_app` repository for full functionality

### Database (`postgres`)
- **Port:** 5432 (exposed for direct access)
- **Credentials:** `badger_admin` / `BadgerPass123!`
- **Database:** `badgers`
- **Init Script:** Creates schema matching AWS RDS configuration
- **Purpose:** Local PostgreSQL instance mirroring RDS deployment

### Cache (`redis`)
- **Port:** 6379 (exposed for direct access)
- **Configuration:** No authentication (development only)
- **Persistence:** Data volume for cache persistence
- **Purpose:** Local Redis instance mirroring ElastiCache deployment

### Admin Tools

#### pgAdmin (`pgadmin`)
- **Port:** 8080
- **Login:** `admin@badgerdelivery.com` / `admin123`
- **Purpose:** Database administration and query interface

#### Redis Commander (`redis-commander`)
- **Port:** 8081
- **Purpose:** Redis key inspection and management

## Infrastructure Testing Workflow

### Initial Setup
```bash
# Clone infrastructure repository
cd mcp_cli_test_infra/docker

# Start infrastructure services
docker-compose up -d

# Check infrastructure service status
docker-compose ps
```

### Running with Application Code
To test with the actual application:

```bash
# Option 1: Mount application code (edit docker-compose.yml)
volumes:
  - ../../mcp_cli_test_app:/app

# Option 2: Build application container separately
# See mcp_cli_test_app repository for application container build instructions
```

### Database Operations
```bash
# Connect to database directly
docker-compose exec postgres psql -U badger_admin -d badgers

# View database schema
docker-compose exec postgres psql -U badger_admin -d badgers -c "\dt"

# Reset database (removes all data)
docker-compose down -v
docker-compose up -d
```

### Infrastructure Debugging
```bash
# View infrastructure service logs
docker-compose logs -f

# Check database status
docker-compose exec postgres pg_isready

# Check Redis connectivity
docker-compose exec redis redis-cli ping

# Inspect network configuration
docker network inspect docker_default
```

## Configuration

### Environment Variables
Copy `env.example` to `.env` and customize:
```bash
cp env.example .env
# Edit .env with your preferred settings
```

### Port Conflicts
If you have port conflicts, update the port mappings in `docker-compose.yml`:
```yaml
ports:
  - "5001:5000"  # Change host port from 5000 to 5001
```

## Infrastructure Testing

### Database Schema
The database is automatically initialized with the schema matching AWS RDS:
- User tables with authentication fields
- Business entity tables
- Relationship tables with proper foreign keys
- Indexes for common query patterns

### Connection Testing
```bash
# Test PostgreSQL connectivity
psql -h localhost -p 5432 -U badger_admin -d badgers -c "SELECT version();"

# Test Redis connectivity
redis-cli -h localhost -p 6379 ping

# Test from within Docker network
docker-compose exec badger-app nc -zv postgres 5432
docker-compose exec badger-app nc -zv redis 6379
```

### Infrastructure Validation
```bash
# Verify all services are healthy
docker-compose ps

# Check resource usage
docker stats

# Inspect network isolation
docker network inspect docker_default
```

## Security Notes

⚠️ **Local Infrastructure Testing Only** ⚠️

This Docker setup is configured for local infrastructure testing and includes several security trade-offs for convenience:

- Database and Redis exposed on host ports for direct access
- Default credentials for easy testing
- No TLS/SSL encryption on local connections
- Permissive network configuration
- Public access to admin interfaces

**This configuration mirrors the development AWS infrastructure but should never be used in production.**

The AWS Terraform configuration (see `../terraform/`) includes additional security controls:
- VPC isolation and security groups
- Encrypted storage and transit
- IAM role-based access control
- Secrets Manager for credential management

## Troubleshooting

### Common Issues

1. **Port already in use:**
   ```bash
   # Check what's using the port
   lsof -i :5000
   # Change port in docker-compose.yml or stop conflicting service
   ```

2. **Database connection failed:**
   ```bash
   # Check if PostgreSQL is running
   docker-compose ps postgres
   # Restart database service
   docker-compose restart postgres
   ```

3. **Application won't start:**
   ```bash
   # Check application logs
   docker-compose logs badger-app
   # Rebuild the image
   docker-compose build badger-app
   ```

4. **Permission issues:**
   ```bash
   # Fix file permissions
   sudo chown -R $USER:$USER ../logs
   ```

### Clean Reset
```bash
# Stop all services and remove volumes
docker-compose down -v

# Remove all images (optional)
docker-compose down --rmi all

# Start fresh
docker-compose up -d
```
