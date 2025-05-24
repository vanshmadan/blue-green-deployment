pipeline {
  agent any

  environment {
    TF_VAR_do_token = credentials('do-api-token') 
    DO_API_TOKEN = credentials('do-api-token')
    AWS_ACCESS_KEY_ID  = credentials('AWS_ACCESS_KEY_ID')
    AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Terraform Init') {
      steps {
        sh 'terraform init'
      }
    }

    stage('Apply Infrastructure (Create Droplets)') {
      steps {
        sh 'terraform apply -auto-approve'
      }
    }

    stage('Identify Active and New Droplets') {
      steps {
        script {
          def floatingIp = sh(script: "terraform output -raw floating_ip", returnStdout: true).trim()
          def blueIp = sh(script: "terraform output -raw blue_ip", returnStdout: true).trim()
          def greenIp = sh(script: "terraform output -raw green_ip", returnStdout: true).trim()
          def blueId = sh(script: "terraform output -raw blue_id", returnStdout: true).trim()
          def greenId = sh(script: "terraform output -raw green_id", returnStdout: true).trim()

          if (floatingIp == blueIp) {
            env.ACTIVE_DROPLET = "blue"
            env.ACTIVE_ID = blueId
            env.NEW_DROPLET = "green"
            env.NEW_ID = greenId
          } else {
            env.ACTIVE_DROPLET = "green"
            env.ACTIVE_ID = greenId
            env.NEW_DROPLET = "blue"
            env.NEW_ID = blueId
          }

          echo "Floating IP is currently on ${env.ACTIVE_DROPLET} (ID: ${env.ACTIVE_ID})"
          echo "Preparing deployment to ${env.NEW_DROPLET} (ID: ${env.NEW_ID})"
        }
      }
    }

    stage('Wait for New Droplet to be Healthy') {
      steps {
        script {
          def newIp = sh(script: "terraform output -raw ${env.NEW_DROPLET}_ip", returnStdout: true).trim()
          timeout(time: 90, unit: 'MINUTES') {
            retry(90) {
              sleep 60
              echo "Checking /health on ${newIp}..."
              sh "curl -sf http://${newIp}/health || exit 1"
            }
          }
        }
      }
    }

    stage('Reassign Floating IP') {
      steps {
        sh """
          terraform apply -auto-approve -var="active_droplet_id=${env.NEW_ID}"
        """
      }
    }

    stage('Destroy Old Droplet') {
      steps {
        script {
          sh "terraform destroy -target=digitalocean_droplet.${env.ACTIVE_DROPLET} -auto-approve"
        }
      }
    }

    stage('Verify Traffic Routing') {
      steps {
        script {
          def floatingIp = sh(script: "terraform output -raw floating_ip", returnStdout: true).trim()
          echo "Verifying /health at ${floatingIp}"
          sh "curl -sf http://${floatingIp}/health"
        }
      }
    }
  }

  post {
    failure {
      echo "Deployment failed. Please check logs and health status."
    }
  }
}
