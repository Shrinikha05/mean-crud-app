# MEAN Stack CRUD Application Deployment

## Overview

In this assignment, I implemented a full-stack CRUD application using the MEAN stack (MongoDB, Express.js, Angular 15, and Node.js). The application manages tutorials with features for creating, reading, updating, deleting, and searching by title. I began by setting up the local development environment, then containerized the application using Docker, deployed it on an AWS EC2 Ubuntu virtual machine, and automated the process with a CI/CD pipeline via GitHub Actions. Nginx was configured as a reverse proxy. All steps were tested locally and in the deployment environment to ensure full functionality.

## Prerequisites

Before starting, I ensured the following were in place:

- A GitHub account for hosting the repository and using GitHub Actions for CI/CD.
- A Docker Hub account for storing container images.
- An AWS account with access to EC2 (utilizing the free tier).
- Local environment with Git, Docker, Docker Compose, Node.js (v16+), and Angular CLI installed.
- An SSH key pair generated for secure EC2 access.

## Repository Setup

I started by creating a new public repository on GitHub named `mean-crud-app`. Then, I initialized the project locally, added the remote origin, and pushed the code:

```
git remote add origin https://github.com/Shrinikha05/mean-crud-app.git
git branch -M main
git push -u origin main
```

Next, I enabled GitHub Actions in the repository settings and added the necessary secrets under Settings > Secrets and variables > Actions:

- `DOCKER_USERNAME`: My Docker Hub username.
- `DOCKER_PASSWORD`: My Docker Hub access token.
- `VM_HOST`: The public IP of the EC2 instance.
- `VM_USER`: `ec2-user` (for Amazon Linux).
- `SSH_PRIVATE_KEY`: The base64-encoded private SSH key.

## Local Development Setup

### Backend Setup
I navigated to the backend directory and installed dependencies:

```
cd backend
npm install
```

I updated the MongoDB configuration in `app/config/db.config.js` to use `mongodb://localhost:27017/dd_db` for local testing. Then, I started the server:

```
node server.js
```

The backend ran on `http://localhost:8080`.

### Frontend Setup
I moved to the frontend directory and installed dependencies:

```
cd frontend
npm install
```

I configured `src/app/services/tutorial.service.ts` to connect to the backend at `http://localhost:8080/api/tutorials`. Then, I started the Angular development server:

```
ng serve --port 8081
```

The application was accessible at `http://localhost:8081`.

### Full Stack Testing Locally
To test the full stack, I ran MongoDB locally using Docker:

```
docker run -d -p 27017:27017 mongo
```

I started the backend and frontend as described above and verified CRUD operations and search functionality in the UI.

## Containerization

After local testing, I created Dockerfiles for containerization:

- **Backend Dockerfile**: Based on Node.js 16 Alpine, it installs dependencies and runs the server on port 8080.
- **Frontend Dockerfile**: A multi-stage build that compiles Angular and serves static files with Nginx on port 80.
- **Docker Compose**: Orchestrates MongoDB, backend, frontend, and Nginx with networking and persistent volumes.

I tested the containerized setup locally:

```
docker-compose up --build
```

The application was accessible at `http://localhost`, with Nginx routing traffic on port 80.

## Deployment on Cloud VM

### AWS EC2 Setup
I launched an EC2 instance on AWS:

- AMI: Amazon Linux 2023 (free tier eligible).
- Instance Type: t2.micro.
- Key Pair: I created a new key pair (`mean-app-key.pem`) and downloaded it.
- Security Group: Configured to allow SSH (port 22) and HTTP (port 80).
- User Data: I used the `user-data.sh` script (included in the repository) to automate initial setup, including installing Docker, Git, Docker Compose, cloning the repository, and setting permissions.

After launch, I connected via SSH:

```
ssh -i mean-app-key.pem ec2-user@<VM_HOST>
```

If the user-data script failed, I manually updated the system and installed dependencies:

```
sudo dnf update -y
sudo dnf install git docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo usermod -aG docker ec2-user
```

Then, I cloned the repository (if not done by script):

```
git clone https://github.com/Shrinikha05/mean-crud-app.git
cd mean-crud-app
```

Finally, I deployed the application:

```
sudo docker-compose up -d --build
```

The app was accessible at `http://<VM_HOST>`.

## CI/CD Pipeline Configuration

I set up GitHub Actions for automation. The workflow (`.github/workflows/deploy.yml`) triggers on pushes to `main`:

- **Build Job**: Logs into Docker Hub and builds/pushes backend and frontend images.
- **Deploy Job**: SSH into the EC2 instance, pulls the latest code, and restarts containers.

I monitored executions in the GitHub Actions tab.

## Nginx Reverse Proxy Setup

Nginx acts as a reverse proxy in the Docker Compose setup:

- It serves frontend static files on `/`.
- It proxies API requests from `/api/*` to the backend.
- Configuration is in `nginx.conf`.

Nginx runs on port 80, providing seamless access without port specifications.

## Testing

- **Local Testing**: I verified CRUD operations, search, and inter-service communication.
- **Deployment Testing**: I confirmed the full stack on EC2 via Docker Compose.
- **CI/CD Testing**: I ensured the pipeline built images, pushed to Docker Hub, and deployed successfully.

## Screenshots

The following screenshots are included in the repository:

- GitHub Actions workflow execution.
- Docker image build and push on Docker Hub.
- Application UI demonstrating CRUD operations.
- EC2 instance infrastructure and Nginx configuration.

## Conclusion

This project meets all assignment requirements: repository setup, containerization, cloud deployment, CI/CD, and reverse proxy. The application is fully functional and tested.
