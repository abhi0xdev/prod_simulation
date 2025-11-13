pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = 'your-registry.com'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Backend') {
            steps {
                script {
                    def backendImage = docker.build("${DOCKER_REGISTRY}/prod-sim-backend:${IMAGE_TAG}", "./backend")
                    backendImage.push("${IMAGE_TAG}")
                    backendImage.push("latest")
                }
            }
        }

        stage('Build Frontend') {
            steps {
                script {
                    def frontendImage = docker.build("${DOCKER_REGISTRY}/prod-sim-frontend:${IMAGE_TAG}", "./frontend")
                    frontendImage.push("${IMAGE_TAG}")
                    frontendImage.push("latest")
                }
            }
        }

        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                script {
                    sh '''
                        # SSH to deployment server and update
                        ssh user@deployment-server << 'EOF'
                            cd /opt/prod-simulation
                            docker-compose pull
                            docker-compose up -d
                            docker-compose ps
                        EOF
                    '''
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}

