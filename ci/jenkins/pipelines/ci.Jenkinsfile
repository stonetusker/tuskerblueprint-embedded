// SensorNode continuous integration (Jenkins multibranch job: sensornode-ci).
//
// Runs for every branch Jenkins discovers by polling the Git repository,
// including main. Replaces the former GitHub Actions pull-request, docs and
// main-branch CI workflows. GitHub is only the Git host.
//
//   every branch  : Go tests and build, specification/YAML/Python/shell/pipeline checks
//   main          : + full Yocto image build, QEMU runtime tests, trusted cache publish
//   other branches: + Yocto build and QEMU tests on request (YOCTO_BUILD), using an
//                     isolated per-branch cache that is never published to MinIO
//
// Optional Jenkins global environment variable MINIO_CACHE_CREDENTIALS_ID names a
// username/password credential for MinIO cache writes. When unset, the agent's
// pre-configured `mc` alias (MINIO_ALIAS, default `tusker`) is used.

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
    buildDiscarder(logRotator(numToKeepStr: '30', artifactNumToKeepStr: '5'))
    timeout(time: 10, unit: 'HOURS')
  }

  parameters {
    booleanParam(name: 'YOCTO_BUILD', defaultValue: false,
                 description: 'Branches other than main: also run the full Yocto build and QEMU tests (isolated cache, never published). Always on for main.')
  }

  environment {
    KAS_FILE = 'kas/ci.yml'
    IMAGE = 'sensornode-image-ci'
    ARTIFACT_DIR = "${WORKSPACE}/artifacts"
    PATH = "/usr/local/go/bin:${env.HOME}/go/bin:${env.PATH}"
  }

  stages {
    stage('Application') {
      steps {
        sh 'make app-test app-build'
      }
    }

    stage('Repository checks') {
      steps {
        sh 'make docs-check python-check yaml-check shell-check pipeline-check policy-check'
      }
    }

    stage('MinIO cache reachable') {
      when { anyOf { branch 'main'; expression { params.YOCTO_BUILD } } }
      steps {
        sh '''
          curl -sSf -m 5 "${MINIO_ENDPOINT:-http://127.0.0.1:9000}/minio/health/live" >/dev/null \
            || echo "[!] MinIO is unreachable; BitBake will build without the shared cache."
        '''
      }
    }

    stage('Yocto build and QEMU test') {
      when { anyOf { branch 'main'; expression { params.YOCTO_BUILD } } }
      steps {
        sh '''#!/bin/bash
          set -Eeuo pipefail
          if [[ "$BRANCH_NAME" == "main" ]]; then
            export CACHE_DIR="$HOME/yocto-cache"
          else
            # Untrusted branches never share or publish the trusted cache.
            export CACHE_DIR="$HOME/yocto-branch-cache/$(printf '%s' "$BRANCH_NAME" | tr -c 'A-Za-z0-9._-' '_')"
          fi
          export GIT_COMMIT="$(git rev-parse --short=7 HEAD)"
          scripts/build-image.sh
          scripts/run-qemu-tests.sh
        '''
      }
    }

    stage('Publish trusted cache') {
      when { branch 'main' }
      environment { CACHE_DIR = "${env.HOME}/yocto-cache" }
      steps {
        script { publishCache() }
      }
    }
  }

  post {
    always {
      junit testResults: 'artifacts/test-reports/*.xml', allowEmptyResults: true
      archiveArtifacts artifacts: 'artifacts/deploy/**, artifacts/release-manifest.json, artifacts/build-duration-seconds, artifacts/oeqa/**',
                       allowEmptyArchive: true, fingerprint: true
    }
  }
}
