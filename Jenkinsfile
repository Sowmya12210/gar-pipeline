pipeline {
    agent any

    environment {
        PROJECT_ID     = "fluted-factor-438905-d2"
        REGION         = "us-west1"
        REPO           = "java-hello-repo"
        IMAGE_NAME     = "javaapplication"
        IMAGE_TAG      = "latest"
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
                    # Decode JSON key & login directly to Artifact Registry
                    cat $GOOGLE_APPLICATION_CREDENTIALS | docker login -u _json_key --password-stdin https://$REGISTRY_URL
                    '''
                }
            }
        }

        stage('Push to Artifact Registry') {
            steps {
                sh "docker push ${FULL_IMAGE}"
            }
        }
    }
}
