pipeline {
    agent any
    environment {
        ENCRYPTED_FILES_SECRET_KEY = credentials('ENCRYPTED_FILES_SECRET_KEY')
    }
    stages {
        // stage('Unit Tests') {
        //     steps {
        //         ansiColor('xterm') {
        //             sh 'scripts/jenkins_build.sh test'
        //             // sh 'scripts/codecov.sh -D . -c'
        //             junit 'Build/reports/**/*.junit'
        //         }
        //     }
        // }
        stage('Deploy') {
            // when {
            //     branch '(master|release\/.*)'
            // }
            steps {
                ansiColor('xterm') {
                    sh 'scripts/jenkins_build.sh adhoc'
                    archiveArtifacts 'Build/Archive.xcarchive'
                }
            }
        }
    }
    post {
        always {
            archiveArtifacts 'Build/build_logs/,Build/reports/,Build/pre_build_action.log'
            sh 'git clean -fd'
        }
    }
}
