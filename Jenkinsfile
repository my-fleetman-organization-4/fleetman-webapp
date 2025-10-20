pipeline {
     agent {
             kubernetes {

        
                 
             yaml """
apiVersion: v1
kind: Pod
spec:
  serviceAccountName: jenkins-sa
  containers:
  - name: maven
    image: israel452/maven-docker:2.0
    command:
    - cat
    tty: true
    volumeMounts:
    - name: docker-sock
      mountPath: /var/run/docker.sock
  - name: node
    image: node:18
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
  stage('Build Angular') {
        steps {
            container('node') {
                sh '''
                  echo "Building Angular app..."
                  npm ci
                  npm run build --prod
                '''
            }
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
               echo "REPOSITORY_TAG usado en el deploy: ${REPOSITORY_TAG}"

              sh 'envsubst < ${WORKSPACE}/deploy.yaml | kubectl apply -f -'
             }
          }
      }
   }
}
