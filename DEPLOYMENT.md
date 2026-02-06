# 🚀 Deployment Documentation – Laravel CI/CD Assignment

## 1. Architecture Overview

```
[ User / Browser ]
        |
        v
[ Nginx Web Server ]
        |
        v
[ Laravel Application (PHP-FPM) ]
        |
        v
[ SQLite Database ]
        |
        v
[ File Storage / Logs ]
```

Components:
- Nginx – Web server
- Laravel (PHP 8.2) – Backend
- SQLite – Database
- Docker – Containerization
- Jenkins – CI/CD
- Docker Hub – Image registry
- AWS EC2 – Production hosting

---

## 2. Local Development Setup

### Prerequisites
- Docker
- Docker Compose
- Git

### Clone and Run Locally

```bash
git clone https://github.com/Deepak-devops1999/laravel-app.git
cd devops-demo
docker-compose up -d
docker-compose exec app php artisan key:generate
docker-compose exec app php artisan migrate
```

Access the app:
```
http://localhost
```

---

## 3. CI/CD Pipeline Explanation

### Trigger
- Pipeline runs automatically on push to `main` branch.

### Pipeline Steps
1. Checkout code from GitHub
2. Inject `.env` securely from Jenkins credentials
3. Build Docker image
4. Run basic sanity checks
5. Push image to Docker Hub
6. Deploy container to AWS EC2

### Secrets Management
- Secrets stored in Jenkins Credentials
- `.env` is never committed to GitHub
- Injected at runtime only

---

## 4. Production Deployment

### Hosting Platform
AWS EC2 (Ubuntu)

### Deployment Steps
1. Launch EC2 instance
2. Install Docker and Jenkins
3. Configure Jenkins credentials
4. Push code to `main`
5. Jenkins builds, pushes, and deploys automatically

### Required Environment Variables

```env
APP_NAME=Laravel
APP_ENV=production
APP_KEY=base64:xxxxxxxxxxxxxxxx
APP_DEBUG=false
APP_URL=http://<EC2_PUBLIC_IP>

DB_CONNECTION=sqlite
DB_DATABASE=/var/www/html/database/database.sqlite
```

Access the app:
```
http://<EC2_PUBLIC_IP>
```

---

## 5. Challenges & Solutions

## Challenge: Docker Image Size and Build Time

## Problem
During CI/CD runs, Docker image builds were slow and produced very large images (600MB+). This increased:
Build time in Jenkins
Image pull time during deployment
Disk usage on the EC2 server
Root Cause
Single-stage Docker build
Composer dependencies and build tools were included in the final runtime image
Unused build layers were retained

## Solution

Implemented a multi-stage Docker build
Used a dedicated Composer build stage
Copied only the final application and dependencies into the runtime image
Separated build-time and runtime dependencies
Cleaned up unused Docker images periodically

## Result

Reduced image size significantly
Faster CI/CD pipeline execution
Cleaner and more maintainable Docker setup

## What I’d Improve 

Use an Alpine-based PHP image


### Improvements with More Time
- Use MySQL instead of SQLite
- Add automated tests
- Implement blue-green deployments
- Add monitoring and HTTPS

