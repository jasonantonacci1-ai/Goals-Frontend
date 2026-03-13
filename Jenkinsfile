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

        stage('UPDATE AND PUSH K8s FILES') {
            steps {
                dir('Goals-Infrastructure') {
                    // 1. Pull the infrastructure code
                    git branch: 'main', credentialsId: 'GitHub', url: 'https://github.com/jasonantonacci1-ai/Goals-Infrastructure.git'
                    
                    // 2. Update the frontend image tag
                    sh "sed -i 's/image: .*/image: ${FRONTEND_IMAGE}:${IMAGE_TAG}/g' client-deployment.yml"
                    
                    // Let's print it out to verify it worked in the logs
                    sh "cat client-deployment.yml"

                    // 3. Commit the changes (only the client file!)
                    sh 'git config --global user.email "jasonantonacci1@gmail.com"'
                    sh 'git config --global user.name "Jason"'
                    sh 'git add client-deployment.yml'
                    sh "git commit -m 'updated frontend tag to ${IMAGE_TAG}'"

                    // 4. Push back to the Infrastructure repo
                    withCredentials([sshUserPrivateKey(credentialsId: 'GitHub', keyFileVariable: 'SSH_KEY')]) {
                        sh 'GIT_SSH_COMMAND="ssh -i $SSH_KEY" git push git@github.com:jasonantonacci1-ai/Goals-Infrastructure.git main'
                    }
                }
            }
        }
