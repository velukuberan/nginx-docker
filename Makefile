# Project variables
SERVICE=nginx
PHP_SERVICE=php-fpm
COMPOSE_FILE=docker-compose.yml
HTTP_PORT=8080
HTTPS_PORT=8443

# Default target
.PHONY: help
help:
	@echo "Available commands:"
	@echo "  up          - Build and start containers in detached mode"
	@echo "  down        - Stop and remove containers"
	@echo "  rebuild     - Rebuild containers without cache (Dockerfile/certs)"
	@echo "  reload      - Reload nginx config and HTML (config/HTML changes)"
	@echo "  restart     - Restart the nginx container"
	@echo "  logs        - View container logs"
	@echo "  bash        - Execute shell inside nginx container"
	@echo "  php-bash    - Execute shell inside PHP container"
	@echo "  ps          - Show running containers"
	@echo "  test        - Test all endpoints"
	@echo "  test-php    - Test PHP functionality"
	@echo "  health      - Check container health"
	@echo "  clean       - Stop containers and cleanup (dangerous!)"
	@echo "  dev         - Start in development mode with auto-reload"
	@echo "  prod        - Start in production mode"
	@echo "  certs       - Generate a new SSL certificate"
	@echo "  ssl-check   - Verify SSL certificate"
	@echo "  php-logs    - View PHP-FPM logs"
	@echo "  php-status  - Check PHP-FPM status and ping"

# Build and start in detached mode
.PHONY: up
up:
	docker compose up --build -d

# Start in development mode (rebuild on changes)
.PHONY: dev
dev:
	@echo "Starting in development mode..."
	docker compose up --build

# Start in production mode
.PHONY: prod
prod:
	@echo "Starting in production mode..."
	docker compose up --build -d
	@make health

# Stop and remove containers
.PHONY: down
down:
	docker compose down

# Rebuild without using cache (use when Dockerfile or certs change)
.PHONY: rebuild
rebuild:
	@echo "Rebuilding containers without cache..."
	docker compose build --no-cache
	docker compose up -d

# Reload nginx config and HTML (use when nginx config or HTML changes)
.PHONY: reload
reload:
	@echo "Reloading nginx configuration..."
	docker compose restart $(SERVICE)
	@echo "Nginx reloaded successfully"

# View logs
.PHONY: logs
logs:
	docker compose logs -f

# View Nginx logs specifically
.PHONY: nginx-logs
nginx-logs:
	docker compose logs -f $(SERVICE)

# View PHP-FPM logs specifically
.PHONY: php-logs
php-logs:
	docker compose logs -f $(PHP_SERVICE)

# Restart the nginx container
.PHONY: restart
restart:
	docker compose restart $(SERVICE)

# Restart PHP-FPM container
.PHONY: php-restart
php-restart:
	docker compose restart $(PHP_SERVICE)

# Execute shell inside the nginx container
.PHONY: bash
bash:
	docker compose exec $(SERVICE) /bin/bash

# Execute shell inside the PHP container
.PHONY: php-bash
php-bash:
	docker compose exec $(PHP_SERVICE) /bin/bash

# Show running containers
.PHONY: ps
ps:
	docker compose ps

# Health check
.PHONY: health
health:
	@echo "Checking container health..."
	@docker compose ps
	@echo "\nTesting HTTP endpoints..."
	@curl -s -o /dev/null -w "HTTP %{http_code}: localhost:$(HTTP_PORT)\n" http://localhost:$(HTTP_PORT) || echo "HTTP endpoint failed"
	@curl -s -o /dev/null -w "HTTPS %{http_code}: localhost:$(HTTPS_PORT)\n" -k https://localhost:$(HTTPS_PORT) || echo "HTTPS endpoint failed"
	@echo "\nTesting PHP..."
	@curl -s -o /dev/null -w "PHP %{http_code}: localhost:$(HTTP_PORT)/phpinfo.php\n" http://localhost:$(HTTP_PORT)/phpinfo.php || echo "PHP endpoint not ready (create phpinfo.php first)"

# Test PHP functionality
.PHONY: test-php
test-php:
	@echo "Testing PHP endpoints..."
	@echo "\n=== PHP Info Test ==="
	@curl -s http://localhost:$(HTTP_PORT)/phpinfo.php | head -20 || echo "❌ PHP Info test failed (create phpinfo.php first)"
	@echo "\n=== PHP Test File ==="
	@curl -s http://localhost:$(HTTP_PORT)/test.php || echo "❌ PHP test file failed (create test.php first)"
	@echo "\n=== PHP Status ==="
	@curl -s http://localhost:$(HTTP_PORT)/status || echo "ℹ️  PHP status page (internal only)"

# Test all configured endpoints
.PHONY: test
test:
	@echo "Testing all configured endpoints..."
	@echo "\n=== Default server ==="
	@curl -s http://localhost:$(HTTP_PORT)/ || echo "Default server test failed"
	@echo "\n=== Test1 server ==="
	@curl -s -H "Host: test1.local" http://localhost:$(HTTP_PORT)/ || echo "Test1 server test failed"
	@echo "\n=== Test2 server ==="
	@curl -s -H "Host: test2.local" http://localhost:$(HTTP_PORT)/ || echo "Test2 server test failed"
	@echo "\n=== SSL Test ==="
	@curl -s -k https://localhost:$(HTTPS_PORT)/ || echo "SSL test failed"
	@echo "\n=== HTML Files Test ==="
	@curl -s http://localhost:$(HTTP_PORT)/html/ || echo "HTML files test failed"
	@echo "\n=== PHP Test ==="
	@make test-php

# Generate a new SSL certificate
.PHONY: certs
certs:
	@echo "Generating new SSL certificates..."
	@if ! command -v mkcert &> /dev/null; then \
		echo "❌ mkcert not found. Please install it first:"; \
		echo "   sudo apt install libnss3-tools"; \
		echo "   curl -JLO 'https://dl.filippo.io/mkcert/latest?for=linux/amd64'"; \
		echo "   chmod +x mkcert-v*-linux-amd64"; \
		echo "   sudo mv mkcert-v*-linux-amd64 /usr/local/bin/mkcert"; \
		echo "   mkcert -install"; \
		echo ""; \
		echo "Then run 'make certs' again."; \
		echo "If it is not working, then do this step manually."; \
		echo "   mkcert -install"; \
		echo "   mkcert -key-file certs/server.key -cert-file certs/server.crt localhost test1.local test2.local 127.0.0.1 ::1"; \
		echo ""; \
		echo "✅ Trusted certificates generated successfully!"; \
		echo ""; \
		echo "📋 Next steps (run these commands manually):"; \
		echo ""; \
		echo "Step 1: Add to hosts file"; \
		echo "echo '127.0.0.1 test1.local test2.local' | sudo tee -a /etc/hosts"; \
		echo ""; \
		echo "Step 2: Restart nginx"; \
		echo "make restart"; \
		echo ""; \
		echo "Step 3: Test everything works"; \
		echo "make test"; \
		echo ""; \
		echo "🔒 After these steps, your browser should show secure connections!"; \
		exit 1; \
		fi
	@echo "Installing local CA (if not already installed)..."
	mkcert -install
	@echo "Creating certificates for localhost, test1.local, test2.local..."
	mkcert -key-file certs/server.key -cert-file certs/server.crt localhost test1.local test2.local 127.0.0.1 ::1
	@echo ""
	@echo "✅ Trusted certificates generated successfully!"
	@echo ""
	@echo "📋 Next steps (run these commands manually):"
	@echo ""
	@echo "# 1. Add to hosts file"
	@echo "echo '127.0.0.1 test1.local test2.local' | sudo tee -a /etc/hosts"
	@echo ""
	@echo "# 2. Restart nginx"
	@echo "make restart"
	@echo ""
	@echo "# 3. Test everything works"
	@echo "make test"
	@echo ""
	@echo "🔒 After these steps, your browser should show secure connections!"

# SSL certificate check
.PHONY: ssl-check
ssl-check:
	@echo "Checking SSL certificate..."
	@openssl x509 -in certs/server.crt -text -noout | grep -E "(Subject|Issuer|Not Before|Not After)"

# Watch logs (useful for debugging)
.PHONY: watch
watch:
	watch -n 2 'docker compose ps && echo "\n--- Recent nginx logs ---" && docker compose logs --tail=5 $(SERVICE) && echo "\n--- Recent PHP logs ---" && docker compose logs --tail=5 $(PHP_SERVICE)'

# Create PHP test files
.PHONY: setup-php-tests
setup-php-tests:
	@echo "Creating PHP test files..."
	@echo '<?php phpinfo(); ?>' > html/phpinfo.php
	@echo '<?php echo "Hello from PHP-FPM! Current time: " . date("Y-m-d H:i:s"); ?>' > html/test.php
	@echo '<?php echo "Index from PHP"; ?>' > html/index.php
	@echo "✅ PHP test files created:"
	@echo "  - html/phpinfo.php"
	@echo "  - html/test.php"
	@echo "  - html/index.php"

# Cleanup everything (⚠️ dangerous!)
.PHONY: clean
clean:
	@echo "⚠️  This will remove all containers, volumes, and networks!"
	@read -p "Are you sure? (y/N): " confirm && [ "$$confirm" = "y" ] || exit 1
	docker compose down -v --remove-orphans
	docker system prune -f
	@echo "Cleanup completed"

# Force clean (no confirmation)
.PHONY: force-clean
force-clean:
	docker compose down -v --remove-orphans
	docker system prune -f

# Show disk usage
.PHONY: disk-usage
disk-usage:
	@echo "Docker disk usage:"
	docker system df

# Check PHP-FPM status
.PHONY: php-status
php-status:
	@echo "PHP-FPM Status:"
	@docker compose exec nginx curl -s http://localhost/status || echo "Status endpoint not accessible"
	@echo "\nPHP-FPM Ping:"
	@docker compose exec nginx curl -s http://localhost/ping || echo "Ping endpoint not accessible"

# Update base images
.PHONY: update
update:
	docker compose pull
	@make rebuild
