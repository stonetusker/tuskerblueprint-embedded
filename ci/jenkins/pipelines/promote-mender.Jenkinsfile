// Promote a signed candidate to Mender (Jenkins job: sensornode-promote-mender).
//
// Replaces the former GitHub Actions promote-mender workflow. A member of
// firmware-production-approvers approves, then the isolated release agent
// downloads the exact candidate, verifies its SHA-256, uploads it to Mender and
// creates a canary-only deployment. Wider rollout is a separate decision.
//
// Credentials: Jenkins secret-text credential `mender-access-token` (override the
// id with the global variable MENDER_CREDENTIALS_ID). MENDER_SERVER_URL defaults to
// https://docker.mender.io.

pipeline {
  agent none

  options {
    timestamps()
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '50'))
    timeout(time: 2, unit: 'HOURS')
  }

  parameters {
    string(name: 'CANDIDATE_URI', defaultValue: '', trim: true, description: 'Immutable candidate URI, e.g. minio://release-evidence/0.4.0/<commit>/sensornode-0.4.0-<commit>.mender')
    string(name: 'EXPECTED_SHA256', defaultValue: '', trim: true, description: 'Expected SHA-256 of the signed candidate')
    string(name: 'ARTIFACT_NAME', defaultValue: '', trim: true, description: 'Mender artifact name, e.g. sensornode-0.4.0-12-1a2b3c4')
    string(name: 'CANARY_DEVICE_IDS', defaultValue: '', trim: true, description: 'Comma-separated Mender device IDs for the canary deployment')
  }

  stages {
    stage('Validate inputs') {
      agent { label 'firmware-release' }
      steps {
        sh '''#!/bin/bash
          set -Eeuo pipefail
          [[ "$CANDIDATE_URI" == minio://release-evidence/* ]] || { echo "CANDIDATE_URI must point into release-evidence" >&2; exit 1; }
          [[ "$EXPECTED_SHA256" =~ ^[0-9a-f]{64}$ ]] || { echo "EXPECTED_SHA256 must be 64 hex characters" >&2; exit 1; }
          [[ -n "$ARTIFACT_NAME" && -n "$CANARY_DEVICE_IDS" ]] || { echo "ARTIFACT_NAME and CANARY_DEVICE_IDS are required" >&2; exit 1; }
        '''
      }
    }

    stage('Approve canary deployment') {
      steps {
        input message: "Deploy ${params.ARTIFACT_NAME} to canary devices ${params.CANARY_DEVICE_IDS}?",
              ok: 'Deploy to canary',
              submitter: 'firmware-production-approvers'
      }
    }

    stage('Upload and deploy to canary') {
      agent { label 'firmware-release' }
      environment {
        MINIO_ALIAS = "${env.RELEASE_MINIO_ALIAS ?: 'tusker-release'}"
        MENDER_SERVER_URL = "${env.MENDER_SERVER_URL ?: 'https://docker.mender.io'}"
        ARTIFACT = 'artifacts/candidate.mender'
        DEVICE_IDS = "${params.CANARY_DEVICE_IDS}"
      }
      steps {
        sh 'rm -rf artifacts && mkdir -p artifacts'
        withEnv(['PATH+RELEASE=/var/lib/tusker-release/bin']) {
          sh 'python3 tools/fetch_candidate.py --uri "$CANDIDATE_URI" --output "$ARTIFACT" --sha256 "$EXPECTED_SHA256"'
          withCredentials([string(credentialsId: env.MENDER_CREDENTIALS_ID ?: 'mender-access-token', variable: 'MENDER_ACCESS_TOKEN')]) {
            sh 'scripts/upload-mender-artifact.sh'
            sh 'scripts/create-mender-deployment.sh'
          }
        }
      }
    }
  }
}
