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
                sh "docker push ${FULL_IMAGE}"
                echo "Image pushed"
            }
        }
    }
}
