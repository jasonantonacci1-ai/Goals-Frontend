pipeline {
    agent any
    environment {
        IMAGE_TAG = "${BUILD_NUMBER}"
        DOCKERHUB_USER = 'jasonantonacci1'
        FRONTEND_APP = "goals_project_frontend"
        FRONTEND_IMAGE = "${DOCKERHUB_USER}/${FRONTEND_APP}"
        }

    stages {
        stage('cleanup Workspace') {
            steps {
                script{
                    cleanWs()
                }   
            }
        }

        stage('Checkout') {
            steps {
                git branch: 'main', credentialsId: 'GitHub', url: 'git@github.com:jasonantonacci1-ai/Goals-Frontend.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build --no-cache -t ${FRONTEND_IMAGE}:${BUILD_NUMBER} -t ${FRONTEND_IMAGE}:latest -f ./Dockerfile .'
                echo "ALL IMAGES BUILT"
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'PASSWORD', usernameVariable: 'USER_NAME')]) {
                    sh 'docker login -u $USER_NAME -p $PASSWORD'
                    sh 'docker push ${FRONTEND_IMAGE}:${BUILD_NUMBER}'
                    sh 'docker push ${FRONTEND_IMAGE}:latest'
                    echo "ALL IMAGES PUSHED"
                    sh 'docker logout'
                        }
                }
        }

        stage("DELETE OLD IMAGES"){
            steps{
                    sh 'docker rmi ${FRONTEND_IMAGE}:${BUILD_NUMBER}'
                    sh 'docker rmi ${FRONTEND_IMAGE}:latest'
            }
        }

        stage('UPDATE K8s DEPLOYMENT FILE') {
             steps {
                 sh 'cat ./k8s/client-deployment.yml'
                sh "sed -i 's/${FRONTEND_APP}.*/${FRONTEND_APP}:${IMAGE_TAG}/g' ./k8s/client-deployment.yml"
                sh 'cat ./k8s/client-deployment.yml'
                sh 'cat ./k8s/server-deployment.yml'
                 }
             }

        stage("PUSH THE CHANGED TAGGED FILE TO GIT MAS"){
            steps{
                sh 'git config --global user.email jasonantonacci1@gmail.com'
                sh 'git config --global user.name jason'
                sh 'git add ./k8s/client-deployment.yml'
                sh 'git add ./k8s/server-deployment.yml'
                sh 'git commit -m "updated tag to ${IMAGE_TAG}"'

                withCredentials([sshUserPrivateKey(credentialsId: 'GitHub', keyFileVariable: 'SSH_KEY')]) {
                    sh 'GIT_SSH_COMMAND="ssh -i $SSH_KEY" git push git@github.com:jasonantonacci1-ai/Goals-Config.git main'
                }
            }
        }
            
     }
}
