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
                        source ~/.bash_profile
                        scripts/jenkins_bootstrap.sh
                        xcode-select -s /Applications/Xcode.app
                        scripts/decrypt_files.sh
                        cp encrypted_files/.env.default .env.default
                        bundle install --jobs=3 --retry=3 --deployment --path=${BUNDLE_PATH:-vendor/bundle}
                        bundle exec fastlane test scheme:safe
                    '''
                }
            }
        }
    }
    post {
        always {
            archiveArtifacts 'Build/build_logs/,Build/reports/,Build/pre_build_action.log'
            junit 'Build/reports/**/*.xml'
            sh 'git clean -fd'
        }
        success {
            ansiColor('xterm') {
                sh 'bash <(curl -s https://codecov.io/bash) -D . -c'
            }
        }
    }
}
