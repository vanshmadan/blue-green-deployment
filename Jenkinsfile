pipeline {
  agent any

  environment {
    DO_API_TOKEN = credentials('do-api-token')
    TF_VAR_ssh_key_id = credentials('ssh_key_id')
    TF_VAR_AWS_ACCESS_KEY_ID     = credentials('do_spaces_key')
    TF_VAR_AWS_SECRET_ACCESS_KEY = credentials('do_spaces_secret')
    AWS_ACCESS_KEY_ID            = credentials('do_spaces_key')
    AWS_SECRET_ACCESS_KEY        = credentials('do_spaces_secret')
  }

  stages {

    stage('Terraform Init') {
      steps {
        sh 'terraform init -reconfigure'
      }
    }

    stage('Terraform Apply Infra') {
      steps {
        sh 'terraform apply -auto-approve'
      }
    }

    stage('Determine Active vs New') {
      steps {
        script {
          def floatingIp = sh(script: "terraform output -raw floating_ip", returnStdout: true).trim()
          def blueId     = sh(script: "terraform output -raw blue_id", returnStdout: true).trim()
          def greenId    = sh(script: "terraform output -raw green_id", returnStdout: true).trim()

          def assignedId = sh(
            script: """
              curl -s -H "Authorization: Bearer $DO_API_TOKEN" \\
              https://api.digitalocean.com/v2/floating_ips/${floatingIp} | jq -r '.floating_ip.droplet.id'
            """, returnStdout: true
          ).trim()

          if (assignedId == "null" || assignedId == "") {
            // First-time apply
            env.FIRST_APPLY = "true"
            env.ACTIVE_DROPLET_ID = blueId
            echo "🟢 First apply detected — assigning IP to blue"
          } else {
            env.FIRST_APPLY = "false"
            if (assignedId == blueId) {
              env.ACTIVE_DROPLET = "blue"
              env.NEW_DROPLET = "green"
              env.ACTIVE_DROPLET_ID = blueId
              env.NEW_DROPLET_ID = greenId
            } else {
              env.ACTIVE_DROPLET = "green"
              env.NEW_DROPLET = "blue"
              env.ACTIVE_DROPLET_ID = greenId
              env.NEW_DROPLET_ID = blueId
            }
            echo "🟠 Active droplet is: ${env.ACTIVE_DROPLET} (${env.ACTIVE_DROPLET_ID})"
          }
        }
      }
    }

    stage('Health Check on New Droplet') {
      when {
        expression { return env.FIRST_APPLY == "false" }
      }
      steps {
        script {
          def newIp = sh(script: "terraform output -raw ${env.NEW_DROPLET}_ip", returnStdout: true).trim()
          timeout(time: 90, unit: 'MINUTES') {
            retry(90) {
              sleep 60
              echo "🌐 Checking health of ${env.NEW_DROPLET} (${newIp})..."
              sh "curl -sf http://${newIp}:8080/health || exit 1"
            }
          }
        }
      }
    }

    stage('Reassign Floating IP') {
      steps {
        script {
          def idToAssign = env.FIRST_APPLY == "true" ? env.ACTIVE_DROPLET_ID : env.NEW_DROPLET_ID
          sh """
            terraform apply -auto-approve \
              -var='active_droplet_id=${idToAssign}'
          """
        }
      }
    }

    stage('Destroy Old Droplet') {
      when {
        expression { return env.FIRST_APPLY == "false" }
      }
      steps {
        sh "terraform destroy -target=digitalocean_droplet.${env.ACTIVE_DROPLET} -auto-approve"
      }
    }

   stage('Verify Final Health') {
  steps {
    script {
      def floatingIp = sh(script: "terraform output -raw floating_ip", returnStdout: true).trim()
      sh "curl -sf http://${floatingIp}:8080/health"
    }
  }
}

  post {
    failure {
      echo "❌ Deployment failed. Check logs and retry."
    }
  }
}
