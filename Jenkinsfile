pipeline {
    agent any
    
    environment {
        // Ensure you have these credentials stored in Jenkins
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKER_IMAGE = "sairevanth286/devops-webapp"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker Image: ${DOCKER_IMAGE}:${IMAGE_TAG}"
                    sh "docker build -t ${DOCKER_IMAGE}:${IMAGE_TAG} -t ${DOCKER_IMAGE}:latest ."
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    echo "Pushing Docker Image to DockerHub"
                    sh "echo ${DOCKERHUB_CREDENTIALS_PSW} | docker login -u ${DOCKERHUB_CREDENTIALS_USR} --password-stdin"
                    sh "docker push ${DOCKER_IMAGE}:${IMAGE_TAG}"
                    sh "docker push ${DOCKER_IMAGE}:latest"
                }
            }
        }

        stage('Deploy to EKS via Ansible') {
            steps {
                script {
                    echo "Updating the image in the Kubernetes Deployment manifest"
                    sh "sed -i 's|sairevanth286/devops-webapp:.*|${DOCKER_IMAGE}:${IMAGE_TAG}|g' k8s/deployment.yaml"
                    
                    echo "Running Ansible Playbook to deploy to Kubernetes"
                    try {
                        // Deploy using Ansible
                        dir('ansible') {
                            sh "ansible-playbook -i inventory.ini deploy-k8s.yml"
                        }
                    } catch (Exception e) {
                        echo "🚨 Deployment Failed! Initiating Kubernetes Rollback..."
                        // Rolls back to the previously stable replica set
                        sh "kubectl rollout undo deployment/ecommerce-app-deployment"
                        error("Deployment failed. Rollback was successfully executed to minimize downtime.")
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully. E-commerce app deployed to EKS!"
        }
        failure {
            echo "Pipeline failed. Please check the logs."
        }
        always {
            // Clean up left over dangling images locally
            sh "docker logout"
            sh "docker rmi ${DOCKER_IMAGE}:${IMAGE_TAG} || true"
        }
    }
}
