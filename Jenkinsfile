pipeline {
    agent any
    triggers{
        githubPush()
    }

    environment {
        GCP_CREDENTIALS = credentials('gcp-key')
        PROJECT_ID     = "fluted-factor-438905-d2"
        REGION         = "us-west1"
        REPO           = "java-hello-repo"
        IMAGE_NAME     = "javaapplication"
        IMAGE_TAG      = "${env.BUILD_NUMBER}"
        REGISTRY_URL   = "${REGION}-docker.pkg.dev"
        FULL_IMAGE     = "${REGISTRY_URL}/${PROJECT_ID}/${REPO}/${IMAGE_NAME}:${IMAGE_TAG}"
        CLUSTER_NAME   = "jenkins-deploy-1" 
        K8S_DEPLOYMENT = "java-app-deployment"
        K8S_SERVICE    = "java-app-service"
        CONTAINER_PORT = "8080"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/Sowmya12210/gar-pipeline.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${FULL_IMAGE} ."
            }
        }
        
        stage('Auth to GCP Artifact Registry') {
            steps {
                withCredentials([file(credentialsId: 'gcp-key', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                    sh '''
                    cat $GOOGLE_APPLICATION_CREDENTIALS | docker login -u _json_key --password-stdin https://$REGISTRY_URL
                    '''
                }
                echo "Auth successful"
            }
        }

        stage('Push to Artifact Registry') {
            steps {
                sh '''
                docker tag ${FULL_IMAGE} ${REGISTRY_URL}/${PROJECT_ID}/${REPO}/${IMAGE_NAME}:latest
                docker push ${FULL_IMAGE}"
                echo "Image pushed"
                '''
            }
        }
        stage('Connect to GKE') {
            steps {
                withCredentials([file(credentialsId: 'gcp-key', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                    sh '''
                        gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
                        gcloud container clusters get-credentials jenkins-deploy-1 --region us-west1 --project fluted-factor-438905-d2
                    '''
                    }
            }
        }

        stage('Prepare Deployment File') {
            steps {
                sh """
                    cp deployment/deployment.yaml deployment/deployment-temp.yaml
                    sed -i 's|REPLACE_IMAGE|${FULL_IMAGE}|g' deployment/deployment-temp.yaml
                """
            }
        }

        stage('Deploy to GKE') {
            steps {
                sh "kubectl apply -f deployment/deployment-temp.yaml"
                sh "kubectl apply -f deployment/service.yaml"
            }
        }

        stage('Verify Deployment') {
            steps {
                sh "kubectl rollout status deployment/${K8S_DEPLOYMENT} --timeout=5m"
                sh "kubectl get svc ${K8S_SERVICE}"
            }
        }
    }
}
