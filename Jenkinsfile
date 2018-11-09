pipeline {
    agent any
    environment {
        ENCRYPTED_FILES_SECRET_KEY = credentials('ENCRYPTED_FILES_SECRET_KEY')
    }
    stages {
        stage('test') {
            steps {
                ansiColor('xterm') {
                    sh '''
                        export PATH="/usr/local/bin:$PATH"
                        export CI="true"
                        source ~/.bash_profile
                        scripts/jenkins_bootstrap.sh
                        scripts/decrypt_files.sh
                        cp encrypted_files/.env.default .env.default
                        bundle install --jobs=3 --retry=3
                        bundle exec fastlane test scheme:safe
                        curl -s https://codecov.io/bash | bash
                    '''
                }
            }
        }
    }
    post {
        always {
            archiveArtifacts 'Build/build_logs/,Build/reports/,Build/pre_build_action.log'
            junit 'Build/reports/**/*.junit'
            sh 'git clean -fd'
        }
    }
}
