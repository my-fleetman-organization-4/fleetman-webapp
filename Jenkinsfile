pipeline {
     agent {
             kubernetes {

        
                 
             yaml """
apiVersion: v1
kind: Pod
spec:
spec:
  serviceAccountName: jenkins-sa
  containers:
  - name: maven
    image:  israel452/maven-docker:2.0
    command:
    - cat
    tty: true
    volumeMounts:
    - name: docker-sock
      mountPath: /var/run/docker.sock
  volumes:
  - name: docker-sock
    hostPath:
      path: /var/run/docker.sock

 """
         }
     }

   environment {
     // You must set the following environment variables
     // ORGANIZATION_NAME
     // YOUR_DOCKERHUB_USERNAME (it doesn't matter if you don't have one)
     
     SERVICE_NAME = "fleetman-webapp"
     REPOSITORY_TAG="${YOUR_DOCKERHUB_USERNAME}/${ORGANIZATION_NAME}-${SERVICE_NAME}:${BUILD_ID}"
   }

   stages {
      stage('Preparation') {
         steps {
            deleteDir() 
            git credentialsId: 'GitHub', url: "https://github.com/${ORGANIZATION_NAME}/${SERVICE_NAME}"
         }
      }
      stage('Build') {
         steps {
            sh 'echo No build required for Webapp.'
            // container('maven') {
            //     sh '''
            //       echo "Building Angular app..."
            //       npm install
            //       npm run build -- --configuration production
            //     ''' docker image build -t ${REPOSITORY_TAG} .
           
            // }
         }
      }

      stage('Build and Push Image') {
         steps {
              container('maven') {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                  sh '''
                    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    docker build --no-cache -t ${REPOSITORY_TAG} .
                    docker push ${REPOSITORY_TAG}
                  '''
                }
                }
            }
      }

      stage('Deploy to Cluster') {
          steps {
             container('maven') {
               // sh 'envsubst < ${WORKSPACE}/deploy.yaml | kubectl apply -f -'

              sh 'envsubst < ${WORKSPACE}/deploy.yaml | kubectl apply -f -'
             }
          }
      }
   }
}
