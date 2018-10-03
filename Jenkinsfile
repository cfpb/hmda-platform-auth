podTemplate(label: 'dockerBuild', containers: [
  containerTemplate(name: 'docker', image: 'docker', ttyEnabled: true, command: 'cat')
],
volumes: [
  hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock'),
]) {
   node('buildHmdaHelp') {
     def repo = checkout scm
     def gitCommit = repo.GIT_COMMIT
     def gitBranch = repo.GIT_BRANCH
     def shortGitCommit = "${gitCommit[0..10]}"

    stage('Build And Publish Docker Image') {
      container('docker') {
        withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'dockerhub',
            usernameVariable: 'DOCKER_HUB_USER', passwordVariable: 'DOCKER_HUB_PASSWORD']]) {
              sh "docker build --rm -t=${env.DOCKER_HUB_USER}/theme-provider ."
              sh "docker tag ${env.DOCKER_HUB_USER}/hmda-help ${env.DOCKER_HUB_USER}/theme-provider:${gitBranch}"
              sh "docker login -u ${env.DOCKER_HUB_USER} -p ${env.DOCKER_HUB_PASSWORD} "
              sh "docker push ${env.DOCKER_HUB_USER}/theme-provider:${gitBranch}"
            }
        }
      }
   }

}