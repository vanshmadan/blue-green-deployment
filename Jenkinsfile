pipeline {
  agent any

  environment {
    TF_VAR_do_token = credentials('do-api-token') 
    DO_API_TOKEN = credentials('do-api-token')
    TF_VAR_AWS_ACCESS_KEY_ID     = credentials('do_spaces_key')
    TF_VAR_AWS_SECRET_ACCESS_KEY = credentials('do_spaces_secret')
    AWS_ACCESS_KEY_ID     = credentials('do_spaces_key')
    AWS_SECRET_ACCESS_KEY = credentials('do_spaces_secret')
    TF_VAR_ssh_key_id = credentials("ssh_key_id")

  }

  stages {
    stage('Terraform Init') {
      steps {
        sh 'terraform init -reconfigure'
      }
    }

    stage('Terraform Output IDs') {
      steps {
        script {
          env.FLOATING_IP = sh(script: "terraform output -raw floating_ip", returnStdout: true).trim()
          env.BLUE_ID     = sh(script: "terraform output -raw blue_id", returnStdout: true).trim()
          env.GREEN_ID    = sh(script: "terraform output -raw green_id", returnStdout: true).trim()
        }
      }
    }

    stage('Detect Active Droplet') {
      steps {
        script {
          def result = sh(
            script: """
              DO_API_TOKEN=${DO_API_TOKEN} bash --debug ./scripts/fetch_active_droplet.sh \
                ${env.FLOATING_IP} ${env.BLUE_ID} ${env.GREEN_ID}
            """,
            returnStdout: true
          ).trim()

          def json = readJSON text: result
          env.ACTIVE_DROPLET_ID = json.active_droplet_id

          if (env.ACTIVE_DROPLET_ID == env.BLUE_ID) {
            env.ACTIVE_DROPLET = "blue"
            env.NEW_DROPLET = "green"
            env.NEW_DROPLET_ID = env.GREEN_ID
          } else {
            env.ACTIVE_DROPLET = "green"
            env.NEW_DROPLET = "blue"
            env.NEW_DROPLET_ID = env.BLUE_ID
          }

          echo "✅ Floating IP currently on ${env.ACTIVE_DROPLET} (${env.ACTIVE_DROPLET_ID})"
        }
      }
    }

    stage('Terraform Apply Infra') {
      steps {
        sh """
          terraform apply -auto-approve \
            -var='active_droplet_id=${env.ACTIVE_DROPLET_ID}'
        """
      }
    }

    stage('Health Check on New Droplet') {
      steps {
        script {
          def newIp = sh(script: "terraform output -raw ${env.NEW_DROPLET}_ip", returnStdout: true).trim()
          timeout(time: 10, unit: 'MINUTES') {
            retry(10) {
              sleep 30
              echo "🌐 Checking /health on ${newIp}..."
              sh "curl -sf http://${newIp}:8080/health || exit 1"
            }
          }
        }
      }
    }

    stage('Reassign Floating IP to New Droplet') {
      steps {
        sh """
          terraform apply -auto-approve \
            -var='active_droplet_id=${env.NEW_DROPLET_ID}'
        """
      }
    }

    stage('Destroy Old Droplet') {
      steps {
        sh "terraform destroy -target=digitalocean_droplet.${env.ACTIVE_DROPLET} -auto-approve"
      }
    }

    stage('Verify Health via Floating IP') {
      steps {
        script {
          def ip = env.FLOATING_IP
          echo "🔁 Verifying final /health check on ${ip}"
          sh "curl -sf http://${ip}:8080/health"
        }
      }
    }
  }

  post {
    failure {
      echo "❌ Deployment failed. Please check logs and health status."
    }
  }
}
