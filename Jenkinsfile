pipeline {
  agent any

  parameters {
    string(name: 'EC2_HOST', defaultValue: '', description: 'EC2 public IP (from terraform output). Leave empty to build and push only.')
  }

  environment {
    REGION   = 'us-east-1'
    SERVICES = 'user-service product-service order-service'
  }

  options {
    timestamps()
    timeout(time: 30, unit: 'MINUTES')
    buildDiscarder(logRotator(numToKeepStr: '15'))
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
        script {
          def sha = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
          env.TAG = "1.0.${env.BUILD_NUMBER}-${sha}"
          withCredentials([usernamePassword(credentialsId: 'aws-jenkins',
                           usernameVariable: 'AWS_ACCESS_KEY_ID',
                           passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
            env.ACCOUNT = sh(returnStdout: true,
              script: 'aws sts get-caller-identity --query Account --output text --region $REGION').trim()
          }
          env.ECR = "${env.ACCOUNT}.dkr.ecr.${env.REGION}.amazonaws.com"
        }
        echo "Release tag: ${env.TAG}"
      }
    }

    stage('Validate config') {
      steps {
        sh 'docker compose -f docker-compose.yml config -q'
        sh 'for s in $SERVICES; do test -f $s/Dockerfile || { echo "Missing $s/Dockerfile"; exit 1; }; done'
        sh 'test -f nginx/nginx.conf'
      }
    }

    stage('Build images') {
      steps {
        sh 'for s in $SERVICES; do docker build -t $ECR/$s:$TAG ./$s; done'
      }
    }

    stage('Test') {
      steps {
        sh 'for s in $SERVICES; do docker run --rm $ECR/$s:$TAG python -m pytest -q -p no:cacheprovider; done'
      }
    }

    stage('Push to ECR') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'aws-jenkins',
                         usernameVariable: 'AWS_ACCESS_KEY_ID',
                         passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
          sh '''
            aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR
            for s in $SERVICES; do docker push $ECR/$s:$TAG; done
          '''
        }
      }
    }

    stage('Deploy to EC2') {
      when { expression { params.EC2_HOST?.trim() } }
      steps {
        withCredentials([sshUserPrivateKey(credentialsId: 'ec2-ssh', keyFileVariable: 'KEY')]) {
          script { env.DEPLOY_STARTED = 'true' }
          sh '''
            SSH_OPTS="-i $KEY -o StrictHostKeyChecking=accept-new"
            scp $SSH_OPTS docker-compose.yml scripts/deploy.sh scripts/rollback.sh ubuntu@$EC2_HOST:/opt/app/
            scp $SSH_OPTS -r nginx ubuntu@$EC2_HOST:/opt/app/
            ssh $SSH_OPTS ubuntu@$EC2_HOST "chmod +x /opt/app/*.sh && /opt/app/deploy.sh $TAG"
          '''
        }
      }
    }

    stage('Verify') {
      when { expression { params.EC2_HOST?.trim() } }
      steps {
        sh '''
          for i in 1 2 3 4 5 6 7 8; do
            if curl -fs http://$EC2_HOST/users/health && curl -fs http://$EC2_HOST/products/health && curl -fs http://$EC2_HOST/orders/health; then
              echo "All services healthy"
              exit 0
            fi
            echo "Not healthy yet, retry $i"
            sleep 10
          done
          exit 1
        '''
      }
    }
  }

  post {
    success {
      echo "Pipeline succeeded, release ${env.TAG}"
    }
    failure {
      script {
        echo 'Pipeline failed'
        if (env.DEPLOY_STARTED == 'true' && params.EC2_HOST?.trim()) {
          echo 'Attempting rollback to the previous version'
          withCredentials([sshUserPrivateKey(credentialsId: 'ec2-ssh', keyFileVariable: 'KEY')]) {
            sh 'ssh -i $KEY -o StrictHostKeyChecking=accept-new ubuntu@$EC2_HOST "/opt/app/rollback.sh" || true'
          }
        }
      }
    }
    always {
      sh 'docker image prune -f || true'
    }
  }
}
