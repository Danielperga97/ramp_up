pipeline {
    agent any
    triggers {
    when { branch 'master' }
    }
    stages {
        stage('build') {
            steps {
                sh 'npm install'
            }
        }
        stage('test') {
            steps {
                sh 'npm test'
            }
        }
        stage('deploy') {
            steps {
                sh 'echo deploying application'
            }
        }
    }
}