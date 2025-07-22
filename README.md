# Docker Nginx + PHP-FPM Setup

A complete Docker setup for running Nginx with PHP-FPM support, including SSL certificates and development tools.

## Features

- 🐳 Docker Compose orchestration
    - 🌐 Nginx web server with custom configuration
- 🐘 PHP 8.2 with FPM (FastCGI Process Manager)
    - 🔒 SSL/HTTPS support with mkcert
    - 🛠️ Complete development workflow via Makefile
    - 📊 Health checks and monitoring endpoints
    - 🔒 Security hardening and best practices

## Quick Start

    1. Clone the repository:
    \`\`\`bash
    git clone https://github.com/YOUR_USERNAME/nginx-php-docker.git
    cd nginx-php-docker
    \`\`\`

    2. Generate SSL certificates:
    \`\`\`bash
    make certs
    \`\`\`

    3. Start the services:
    \`\`\`bash
    make up
    \`\`\`

    4. Test the setup:
    \`\`\`bash
    make test
    \`\`\`

## Available Commands

    - \`make up\` - Start containers
    - \`make down\` - Stop containers  
    - \`make test\` - Test all endpoints
    - \`make logs\` - View logs
    - \`make certs\` - Generate SSL certificates

## Access Points

    - HTTP: http://localhost:8080
    - HTTPS: https://localhost:8443
    - PHP Info: http://localhost:8080/phpinfo.php

## Project Structure

    \`\`\`
    ├── docker-compose.yml    # Container orchestration
    ├── Dockerfile           # Custom Nginx image
    ├── Makefile            # Development commands
    ├── nginx/              # Nginx configuration
    ├── php/                # PHP-FPM configuration  
    ├── html/               # Website content
└── certs/              # SSL certificates (auto-generated)
    \`\`\`

## License

    MIT License - see LICENSE file for details.
