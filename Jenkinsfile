pipeline {
    agent any

    environment {
        DOCKER_CREDS = credentials('dockerhub-cred')
        ENV_FILE     = credentials('laravel-env')
        IMAGE_NAME   = 'deepaksharma1999/laravel-assignment'
        CONTAINER_NAME = 'laravel-app'
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Deepak-devops1999/laravel-app.git'
            }
        }

        stage('Create .env from Jenkins Credentials') {
            steps {
                sh '''
                echo "$ENV_FILE" > .env
                '''
            }
        }

        stage('Build Docker Image (Basic Test)') {
            steps {
                sh '''
                docker build -t $IMAGE_NAME:latest .
                '''
            }
        }

        stage('Application Sanity Check') {
            steps {
                sh '''
                docker run --rm \
                  --env-file .env \
                  $IMAGE_NAME:latest \
                  php artisan --version
                '''
            }
        }

        stage('Login to Docker Hub') {
            steps {
                sh '''
                echo $DOCKER_CREDS_PSW | docker login \
                  -u $DOCKER_CREDS_USR --password-stdin
                '''
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                sh 'docker push $IMAGE_NAME:latest'
            }
        }

        stage('Deploy to AWS EC2') {
            steps {
                sh '''
                docker stop $CONTAINER_NAME || true
                docker rm $CONTAINER_NAME || true

                docker run -d \
                  --name $CONTAINER_NAME \
                  -p 80:8000 \
                  --env-file .env \
                  $IMAGE_NAME:latest
                '''
            }
        }
    }

    post {
        success {
            echo '✅ Deployment successful'
        }
        failure {
            echo '❌ Deployment failed'
        }
    }
}

