def app

pipeline {
    agent any

    environment {
        EMAIL_TO = 'team@example.com'
        EMAIL_REPLY_TO = 'jenkins@example.com'
        EMAIL_MIME_TYPE = 'text/html'
        EMAIL_ATTACH_LOG = 'true'

        // leave it blank if Docker Hub
        REGISTRY_URL = ''
        CREDENTIALS_ID = 'dockerhub'
        REPO_NAME = 'jodykpw/universal-nginx-php73'
        TAG = '1.0.0'
        COMMIT_SHORT_SHA = """${sh(
                returnStdout: true,
                script: 'git rev-parse --short=8 HEAD'
            ).trim()}"""
        DEV_TAG = "${env.TAG}-${env.BRANCH_NAME}-${env.COMMIT_SHORT_SHA}"
    }

    stages {
        stage("SCM") {
            steps {
                echo "========Executing stage: SCM========"
                echo 'Pulling...' + env.BRANCH_NAME
                checkout scm
            }
            post {
                success {
                    echo "========SCM: executed successfully========"
                }
                failure {
                    echo "========SCM: execution failed========"
                }
            }
        }

        stage("Build") {
            steps{
                echo "========Executing stage: Build========"

                script {
                    if ( env.BRANCH_NAME == "master" ) {
                        app = docker.build("${env.REPO_NAME}:${TAG}")
                                        
                    } else {
                        app = docker.build("${env.REPO_NAME}:${env.DEV_TAG}")
                    }
                }

            }
            post {
                success {
                    echo "========Build: executed successfully========"
                }
                failure {
                    echo "========Build: execution failed========"
                }
            }
        }

        stage("Docker Composer Up") {
            steps {
                echo "========Executing stage: Docker Composer Up========"

                sh "REPO_NAME=${env.REPO_NAME} TAG=${env.DEV_TAG} docker-compose -f docker-compose-build-test.yml up -d"
            }
            post{
                success {
                    echo "========Docker Composer Up: executed successfully========"
                }
                failure {
                    echo "========Docker Composer Up: execution failed========"
                }
            }
        }

        stage("Test Docker Container") {
            steps {
                echo "========Executing stage: Test Docker Container========"

                script {
                    try {
                        sh 'sleep 20'
                        sh 'docker exec -i  universal-nginx-php-test nginx -c /etc/nginx/nginx.conf -t'
                        sh 'docker exec -i  universal-nginx-php-test php -m'
                        sh 'docker exec -i  universal-nginx-php-test composer -v'
                        sh 'docker exec -i  universal-nginx-php-test curl --silent --show-error --fail http://localhost/healthz' 
                        sh 'docker exec -i  universal-nginx-php-test curl --silent --show-error --fail http://localhost:9001/status/format/json' 
                        sh 'docker exec -i  universal-nginx-php-test curl --silent --show-error --fail http://localhost:9000/status' 
                        sh 'docker exec -i  universal-nginx-php-test ps aux'                         
                    } catch (Exception e) {
                        sh "REPO_NAME=${env.REPO_NAME} TAG=${env.DEV_TAG} docker-compose -f docker-compose-build-test.yml down"

                        if ( env.BRANCH_NAME != "master" ) {
                            sh "docker rmi ${env.REPO_NAME}:${env.DEV_TAG}"
                        }

                        sh 'exit 1'
                    }
                }

            }
            post {
                success {
                    echo "========Test Docker Container: executed successfully========"
                }
                failure {
                    echo "========Test Docker Container: execution failed========"
                }
            }
        }

        stage("Docker Composer Down") {
            steps {
                echo "========Executing stage: Docker Composer Down========"
                sh "REPO_NAME=${env.REPO_NAME} TAG=${env.DEV_TAG} docker-compose -f docker-compose-build-test.yml down"

                script {
                    if ( env.BRANCH_NAME != "master" ) {
                        sh "docker rmi ${env.REPO_NAME}:${env.DEV_TAG}"
                    }
                }
            }
            post {
                success{
                    echo "========Docker Composer Down: executed successfully========"
                }
                failure{
                    echo "========Docker Composer Down: execution failed========"
                }
            }
        }

        stage("Release to Docker Hub") {
            when {
                expression { env.BRANCH_NAME == "master" }
            }
            steps {
                echo "========Executing stage: Release========"

                script {
                    docker.withRegistry("", "${env.CREDENTIALS_ID}") {
                        app.push()
                    }
                }

            }
            post {
                success {
                    echo "========Release: executed successfully========"
                }
                failure {
                    echo "========Release: execution failed========"
                }
            }
        }

    }

    post {
        success {
            echo "========Pipeline executed successfully ========"

            emailext(body: "The pipeline ${env.BUILD_URL} completed successfully.", mimeType: "${EMAIL_MIME_TYPE}",
                replyTo: "${EMAIL_REPLY_TO}", subject: "Success Pipeline: ${currentBuild.fullDisplayName}",
                to: "${EMAIL_TO}", attachLog: "${EMAIL_ATTACH_LOG}")
        }
        failure {
            echo "========Pipeline execution failed========"

            emailext(body: "Something is wrong with ${env.BUILD_URL}", mimeType: "${EMAIL_MIME_TYPE}",
                replyTo: "${EMAIL_REPLY_TO}", subject: "Failed Pipeline: ${currentBuild.fullDisplayName}",
                to: "${EMAIL_TO}", attachLog: "${EMAIL_ATTACH_LOG}")
        }
    }
}