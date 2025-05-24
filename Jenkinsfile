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

  stage('Determine Active Droplet via API') {
  steps {
    script {
      def floatingIp = sh(script: "terraform output -raw floating_ip", returnStdout: true).trim()
      def blueId     = sh(script: "terraform output -raw blue_id", returnStdout: true).trim()
      def greenId    = sh(script: "terraform output -raw green_id", returnStdout: true).trim()

      def dropletId = sh(
        script: """
          curl -s -H "Authorization: Bearer $DO_API_TOKEN" \\
          https://api.digitalocean.com/v2/floating_ips/${floatingIp} | \\
          jq -r '.floating_ip.droplet.id'
        """,
        returnStdout: true
      ).trim()

      if (dropletId == blueId) {
        env.ACTIVE_DROPLET = "blue"
        env.ACTIVE_ID = blueId
        env.NEW_DROPLET = "green"
        env.NEW_ID = greenId
      } else if (dropletId == greenId) {
        env.ACTIVE_DROPLET = "green"
        env.ACTIVE_ID = greenId
        env.NEW_DROPLET = "blue"
        env.NEW_ID = blueId
      } else {
        error("Floating IP is not assigned to blue or green droplet. ID: ${dropletId}")
      }

      echo "✅ Floating IP is currently assigned to: ${env.ACTIVE_DROPLET} (${env.ACTIVE_ID})"
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
          sh "curl -sf http://${floatingIp}:8080/health"
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
