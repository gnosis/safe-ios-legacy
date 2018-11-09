pipeline {
    agent any
    environment {
        ENCRYPTED_FILES_SECRET_KEY = credentials('ENCRYPTED_FILES_SECRET_KEY')
    }
    stages {
        stage('Test') {
            stage('Unit Tests') {
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
                        '''
                        // sh 'scripts/codecov.sh -D . -c'
                        junit 'Build/reports/**/*.junit'
                    }
                }
            }
            stage('UI Tests') {
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
                            bundle exec fastlane test scheme:allUITests
                        '''
                        junit 'Build/reports/**/*.junit'
                    }
                }
            }
        }
        stage('Deploy') {
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
                        bundle exec fastlane fabric
                    '''
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
