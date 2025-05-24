pipeline {
  agent any

  environment {
    TF_VAR_do_token = credentials('do-api-token')
    TF_VAR_ssh_key_id = credentials('ssh_key_id')
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Init Terraform') {
      steps {
        sh 'terraform init'
      }
    }

    stage('Get Active Droplet ID') {
      steps {
        script {
          def currentId = sh(script: "terraform output -raw blue_id", returnStdout: true).trim()
          def currentIP = sh(script: "terraform output -raw floating_ip", returnStdout: true).trim()
          def blueIP = sh(script: "terraform output -raw blue_ip", returnStdout: true).trim()

          env.ACTIVE_DROPLET = currentIP == blueIP ? "blue" : "green"
          env.NEW_DROPLET = env.ACTIVE_DROPLET == "blue" ? "green" : "blue"
        }
      }
    }

    stage('Apply Infra') {
      steps {
        sh 'terraform apply -auto-approve'
      }
    }

    stage('Wait for /health') {
      steps {
        script {
          def newIp = sh(script: "terraform output -raw ${env.NEW_DROPLET}_ip", returnStdout: true).trim()
          timeout(time: 90, unit: 'MINUTES') {
            retry(30) {
              sleep 60
              sh "curl -sf http://${newIp}/health || exit 1"
            }
          }
        }
      }
    }

    stage('Reassign Floating IP') {
      steps {
        script {
          def newId = sh(script: "terraform output -raw ${env.NEW_DROPLET}_id", returnStdout: true).trim()
          sh "terraform apply -auto-approve -var active_droplet_id=${newId}"
        }
      }
    }

    stage('Destroy Old Droplet') {
      steps {
        script {
          sh "terraform destroy -target=digitalocean_droplet.${env.ACTIVE_DROPLET} -auto-approve"
        }
      }
    }

    stage('Verify Routing') {
      steps {
        script {
          def ip = sh(script: "terraform output -raw floating_ip", returnStdout: true).trim()
          sh "curl -sf http://${ip}/health"
        }
      }
    }
  }
}
