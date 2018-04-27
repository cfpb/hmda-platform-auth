pipeline {

  agent {
    docker {
      image 'cfpb/jenkinsfile:base'
      args '--user jenkins -v /run/docker.sock:/run/docker.sock'
    }
  }

  environment {
    KEYCLOAK_IMAGE_NAME = 'hmda/keycloak'
    AUTH_PROXY_IMAGE_NAME_AUTH_PROXY = 'hmda/auth-proxy'

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

          env.KEYCLOAK_IMAGE_NAME_WITH_TAG = "${env.DOCKER_REGISTRY}/${env.KEYCLOAK_IMAGE_NAME}:${env.BRANCH_NAME}-${env.BUILD_ID}"
          env.AUTH_PROXY_IMAGE_NAME_WITH_TAG = "${env.DOCKER_REGISTRY}/${env.AUTH_PROXY_IMAGE_NAME}:${env.BRANCH_NAME}-${env.BUILD_ID}"

          currentBuild.changeSets.each { changeSets ->
            changeSets.items.each {
              csItem
            }
          }
        }

        // This `docker login` seems to be required with each run of the job when running inside a container.
        // It seems this is necessary because `docker.withRegistry()` credentials only perform a `docker login`
        // correctly for some versions of Docker.  This may go away upon future Docker versions.
        sh 'docker login --username $DOCKER_REGISTRY_CREDENTIALS_USR --password $DOCKER_REGISTRY_CREDENTIALS_PSW $DOCKER_REGISTRY_URL'
      }
    }

    stage('select app build') {
      steps {
        script {
          env.BUILD_KEYCLOAK = false
          env.BUILD_AUTH_PROXY = false
          
          currentBuild.changeSets.each { changeLogSet ->
            changeLogSet.items.each { entry ->
              echo "${entry.commitId} by ${entry.author} on ${new Date(entry.timestamp)}: ${entry.msg}\n"
              entry.affectedFiles.each { file ->
                echo "  ${file.editType.name} ${file.path}"
                if (file.path.startsWith('keycloak/')) env.BUILD_KEYCLOAK = true
                if (file.path.startsWith('auth-proxy/')) env.BUILD_KEYCLOAK = true
              }
            }
          }

          if (!env.BUILD_KEYCLOAK && !env.BUILD_AUTH_PROXY) {
              echo "Could not determine which app to build, so building both"
              env.BUILD_KEYCLOAK = true
              env.BUILD_AUTH_PROXY = true
          }
        }
        sh 'env | sort'
      }
    }

}