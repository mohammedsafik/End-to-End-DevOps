pipeline {
  agent any

  environment {
    AWS_REGION = 'us-east-1'
    TF_VAR_key_name = 'mykeypair'
  }

  stages {
    stage('Terraform Init') {
      steps {
        dir('terraform') {
          sh 'terraform init'
        }
      }
    }

    stage('Terraform Apply') {
      steps {
        dir('terraform') {
          sh 'terraform apply -auto-approve'
        }
      }
    }

    stage('Build & Push Docker Image') {
      steps {
        dir('app') {
          script {
            dockerImage = docker.build("yourdockerhub/devops-nodejs-app:latest")
            docker.withRegistry('https://index.docker.io/v1/', 'docker-hub-credentials') {
              dockerImage.push()
            }
          }
        }
      }
    }

    stage('Kubernetes Deploy') {
      steps {
        dir('manifests') {
          sh 'kubectl apply -f deployment.yaml'
        }
      }
    }

    stage('Monitoring Setup') {
      steps {
        dir('scripts') {
          sh './install-prometheus-grafana.sh'
        }
      }
    }
  }
}

