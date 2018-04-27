pipeline {

  agent {
    docker {
      image 'cfpb/jenkinsfile:nodejs'
      args '--user jenkins -v /run/docker.sock:/run/docker.sock'
    }
  }

  environment {
    AUTH_PROXY_IMAGE_NAME = 'hmda/auth-proxy'
    KEYCLOAK_IMAGE_NAME = 'hmda/keycloak'
    DOCKER_REGISTRY_CREDENTIALS_ID = 'hmda-platform-jenkins-service'
  }

  options {
    ansiColor('xterm')
    timestamps()
  }

  stages {

    stage('init') {
      environment {
        DOCKER_REGISTRY_CREDENTIALS = credentials("${env.DOCKER_REGISTRY_CREDENTIALS_ID}")
      }
      steps {
        script {
          // Add additional global envvars here since pipelines do not allow you to reference one another in `environment` section
          env.DOCKER_REGISTRY = env.DOCKER_REGISTRY_URL - 'https://'

          env.AUTH_PROXY_IMAGE_NAME_WITH_TAG = "${env.DOCKER_REGISTRY}/${env.AUTH_PROXY_IMAGE_NAME}:${env.BRANCH_NAME}-${env.BUILD_ID}"
          env.AUTH_PROXY_IMAGE_REPO  = "${env.DOCKER_REGISTRY_URL}/repositories/${env.AUTH_PROXY_IMAGE_NAME}"

          env.KEYCLOAK_IMAGE_NAME_WITH_TAG = "${env.DOCKER_REGISTRY}/${env.KEYCLOAK_IMAGE_NAME}:${env.BRANCH_NAME}-${env.BUILD_ID}"
          env.KEYCLOAK_IMAGE_REPO  = "${env.DOCKER_REGISTRY_URL}/repositories/${env.KEYCLOAK_IMAGE_NAME}"
        }

        // This `docker login` seems to be required with each run of the job when running inside a container.
        // It seems this is necessary because `docker.withRegistry()` credentials only perform a `docker login`
        // correctly for some versions of Docker.  This may go away upon future Docker versions.
        sh 'docker login --username $DOCKER_REGISTRY_CREDENTIALS_USR --password $DOCKER_REGISTRY_CREDENTIALS_PSW $DOCKER_REGISTRY_URL'

        sh 'env | sort'
      }
    }

    stage('build images') {
      steps {
        script {
          docker.build(env.AUTH_PROXY_IMAGE_NAME_WITH_TAG)
          docker.build(env.KEYCLOAK_IMAGE_NAME_WITH_TAG)
        }
      }
    }

    stage('publish images') {
      steps {
        script {
          docker.withRegistry(env.DOCKER_REGISTRY_URL, env.DOCKER_REGISTRY_CREDENTIALS_ID) {
            docker.image(env.AUTH_PROXY_IMAGE_NAME_WITH_TAG).push()
            docker.image(env.KEYCLOAK_IMAGE_NAME_WITH_TAG).push()
          }
        }
      }
    }

  }

  post {
    success {
      echo """Docker images successfully pushed to ${env.DOCKER_REGISTRY_URL}:
      * ${env.AUTH_PROXY_IMAGE_NAME_WITH_TAG}
      * ${env.KEYCLOAK_IMAGE_NAME_WITH_TAG}
      """
    }
  }

}