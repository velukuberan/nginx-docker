# Convert Existing Project to Git + GitHub

## Step 1: Initialize Git Repository Locally

Navigate to your project directory and initialize Git:

```bash
# Go to your project directory
cd /path/to/your/nginx-php-project

# Initialize Git repository
git init

# Check status (see all untracked files)
git status
```

## Step 2: Create .gitignore File

Create a `.gitignore` file to exclude files that shouldn't be tracked:

```bash
# Create .gitignore file
nano .gitignore
```

**Recommended .gitignore content:**
```gitignore
# SSL Certificates (regenerate these)
certs/
*.crt
*.key
*.pem

# Docker volumes and logs
.docker/
*.log

# Environment files (if you add them later)
.env
.env.local
.env.production

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# IDE files
.vscode/
.idea/
*.swp
*.swo
*~

# Temporary files
*.tmp
*.temp
tmp/
temp/

# Docker build cache
.dockerignore

# Logs
logs/
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
```

## Step 3: Add Files to Git

```bash
# Add all files to staging
git add .

# Or add files selectively
git add docker-compose.yml
git add Dockerfile
git add Makefile
git add nginx/
git add php/
git add html/

# Check what's staged
git status

# Make initial commit
git commit -m "Initial commit: Docker Nginx + PHP-FPM setup"
```

## Step 4: Create GitHub Repository

**Option A: Via GitHub Web Interface**
1. Go to [github.com](https://github.com)
2. Click "+" → "New repository"
3. Repository name: `nginx-php-docker` (or your preferred name)
4. Description: "Docker setup for Nginx + PHP-FPM with SSL support"
5. **Important**: Choose "Public" or "Private"
6. **Don't initialize** with README, .gitignore, or license (since you already have files)
7. Click "Create repository"

**Option B: Via GitHub CLI (if installed)**
```bash
# Install GitHub CLI first (if not installed)
# Ubuntu/Debian: sudo apt install gh
# macOS: brew install gh

# Login to GitHub
gh auth login

# Create repository
gh repo create nginx-php-docker --public --source=. --push
```

## Step 5: Connect Local Repository to GitHub

Copy the commands from GitHub's "push an existing repository" section:

```bash
# Add GitHub as remote origin
git remote add origin https://github.com/YOUR_USERNAME/nginx-php-docker.git

# Verify remote was added
git remote -v

# Push to GitHub (first time)
git branch -M main
git push -u origin main
```

## Step 6: Verify Everything Worked

**Check on GitHub:**
- Go to your repository URL
- Verify all files are there
- Check that sensitive files (certs/) are excluded

**Local verification:**
```bash
# Check remote connection
git remote show origin

# Check branch status
git status
```

## Step 7: Create a Good README.md

Create a README file for your project:

```bash
nano README.md
```

**Sample README content:**
```markdown
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
```

Add and commit the README:
```bash
git add README.md
git commit -m "Add comprehensive README documentation"
git push origin main
```

## Step 8: Optional Enhancements

**Add a LICENSE file:**
```bash
# Create LICENSE file (MIT example)
curl -s https://api.github.com/licenses/mit | grep -Po '"body": "\K.*?(?=")' | sed 's/\\n/\n/g' > LICENSE

# Add your name and year
sed -i 's/\[year\]/2025/g' LICENSE
sed -i 's/\[fullname\]/Your Name/g' LICENSE

git add LICENSE
git commit -m "Add MIT license"
git push origin main
```

**Create GitHub Issues/Templates:**
- Go to your repo → Settings → Features → Issues
- Create issue templates for bugs and feature requests

## Future Workflow

Now that it's a Git repository:

```bash
# Daily workflow
git add .
git commit -m "Update nginx configuration"
git push origin main

# Create feature branches
git checkout -b feature/add-redis
# ... make changes ...
git commit -m "Add Redis support"
git push origin feature/add-redis
# Create pull request on GitHub
```

## SSL Certificates Note

Since `certs/` is in `.gitignore`, each person who clones the repo needs to run:
```bash
make certs  # Generates local SSL certificates
```

This is intentional - SSL certificates should not be shared in Git for security reasons.

## Summary

✅ Your existing project is now a proper Git repository  
✅ Connected to GitHub for remote backup and collaboration  
✅ Proper .gitignore excludes sensitive/generated files  
✅ Good documentation for other developers  
✅ Ready for collaborative development  

The project can now be cloned, forked, and collaborated on by others!
