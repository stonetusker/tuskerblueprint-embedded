// SensorNode nightly build and cache refresh (Jenkins job: sensornode-nightly).
//
// Replaces the former GitHub Actions nightly and manual build-image workflows.
// Runs on main every night at 02:00 UTC; "Build with Parameters" runs it on
// demand (for example without the cache publish).

def publishCache() {
  withEnv(['CACHE_WRITE_ALLOWED=1']) {
    if (env.MINIO_CACHE_CREDENTIALS_ID?.trim()) {
      withCredentials([usernamePassword(credentialsId: env.MINIO_CACHE_CREDENTIALS_ID,
                                        usernameVariable: 'MINIO_ACCESS_KEY',
                                        passwordVariable: 'MINIO_SECRET_KEY')]) {
        sh 'mc --no-color alias set "${MINIO_ALIAS:-tusker}" "${MINIO_ENDPOINT:-http://127.0.0.1:9000}" "$MINIO_ACCESS_KEY" "$MINIO_SECRET_KEY" >/dev/null'
        sh 'scripts/cache-sync.sh push'
      }
    } else {
      echo 'MINIO_CACHE_CREDENTIALS_ID not set: using the agent\'s pre-configured mc alias.'
      sh 'scripts/cache-sync.sh push'
    }
  }
}

pipeline {
  agent { label 'yocto-vps8' }

  options {
    timestamps()
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '14', artifactDaysToKeepStr: '7'))
    timeout(time: 10, unit: 'HOURS')
  }

  triggers {
    cron('''TZ=UTC
0 2 * * *''')
  }

  parameters {
    booleanParam(name: 'CLEAN_TMP', defaultValue: true, description: 'Remove build/tmp first (keeps downloads and sstate) so the run is a regression build')
    booleanParam(name: 'QEMU_TEST', defaultValue: true, description: 'Run the QEMU runtime tests after the build')
    booleanParam(name: 'PUSH_CACHE', defaultValue: true, description: 'Publish the refreshed downloads and sstate to MinIO')
  }

  environment {
    KAS_FILE = 'kas/ci.yml'
    IMAGE = 'sensornode-image-ci'
    CACHE_DIR = "${HOME}/yocto-cache"
    ARTIFACT_DIR = "${WORKSPACE}/artifacts"
  }

  stages {
    stage('Clean build/tmp') {
      when { expression { params.CLEAN_TMP } }
      steps { sh 'rm -rf build/tmp' }
    }

    stage('Yocto build') {
      steps {
        sh '''
          export GIT_COMMIT="$(git rev-parse --short=7 HEAD)"
          scripts/build-image.sh
        '''
      }
    }

    stage('QEMU test') {
      when { expression { params.QEMU_TEST } }
      steps { sh 'scripts/run-qemu-tests.sh' }
    }

    stage('Publish cache') {
      when { expression { params.PUSH_CACHE } }
      steps { script { publishCache() } }
    }
  }

  post {
    always {
      junit testResults: 'artifacts/test-reports/*.xml', allowEmptyResults: true
      archiveArtifacts artifacts: 'artifacts/deploy/**, artifacts/release-manifest.json, artifacts/build-duration-seconds',
                       allowEmptyArchive: true, fingerprint: true
    }
  }
}
