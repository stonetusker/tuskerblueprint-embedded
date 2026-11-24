// SensorNode signed release candidate (Jenkins job: sensornode-release-candidate).
//
// Replaces the former GitHub Actions release-candidate workflow.
//
//  1. On the build agent (yocto-vps8): verify the commit is on main, validate the
//     source lock, build the Mender release image, test the exact release disk in
//     QEMU, collect the SBOM and keep the unsigned candidate.
//  2. A member of firmware-signing-approvers approves signing (no executor held).
//  3. On the isolated release agent (firmware-release): sign the exact candidate
//     with the key that only that agent holds, publish it write-once to MinIO,
//     then push the annotated release tag v<VERSION> to GitHub (tag ref only).
//
// The build agent never sees the signing key; the release agent never runs Docker
// or touches the Yocto cache.

pipeline {
  agent none

  options {
    timestamps()
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '30', artifactNumToKeepStr: '10'))
    timeout(time: 12, unit: 'HOURS')
  }

  parameters {
    string(name: 'VERSION', defaultValue: '', trim: true, description: 'Semantic version, for example 0.4.0')
    string(name: 'SOURCE_COMMIT', defaultValue: '', trim: true, description: 'Full 40-character commit that is already on main')
    booleanParam(name: 'SIGN_AND_PUBLISH', defaultValue: true,
                 description: 'After approval, sign on the firmware-release agent and publish the immutable candidate. Untick for a tested, unsigned candidate only.')
  }

  stages {
    stage('Build and test candidate') {
      agent { label 'yocto-vps8' }
      environment {
        KAS_FILE = 'kas/release.yml'
        IMAGE = 'sensornode-image-release'
        SENSORNODE_VERSION = "${params.VERSION}"
        CACHE_DIR = "${HOME}/yocto-cache"
        ARTIFACT_DIR = "${WORKSPACE}/artifacts"
        SOURCE_LOCK_CONFIG = 'kas/source-lock.yml'
      }
      stages {
        stage('Validate inputs') {
          steps {
            sh '''#!/bin/bash
              set -Eeuo pipefail
              if [[ -z "${VERSION:-}" || -z "${SOURCE_COMMIT:-}" ]]; then
                echo "VERSION and SOURCE_COMMIT are required: use Build with Parameters." >&2
                exit 1
              fi
              [[ "$VERSION" =~ ^[0-9]+\\.[0-9]+\\.[0-9]+([+-][0-9A-Za-z.-]+)?$ ]] || { echo "VERSION must be a semantic version" >&2; exit 1; }
              [[ "$SOURCE_COMMIT" =~ ^[0-9a-f]{40}$ ]] || { echo "SOURCE_COMMIT must be a full 40-character commit" >&2; exit 1; }
            '''
          }
        }

        stage('Check out exact commit on main') {
          steps {
            sh '''#!/bin/bash
              set -Eeuo pipefail
              git fetch --prune origin '+refs/heads/main:refs/remotes/origin/main'
              git checkout --detach "$SOURCE_COMMIT"
              git merge-base --is-ancestor "$SOURCE_COMMIT" origin/main
              # Fail now, not after a long build, if v$VERSION already marks another commit.
              existing="$(git ls-remote --tags origin "refs/tags/v${VERSION}^{}" "refs/tags/v${VERSION}" | awk '{print $1}' | tail -n 1)"
              if [[ -n "$existing" && "$existing" != "$SOURCE_COMMIT" ]]; then
                echo "tag v${VERSION} already exists at $existing; choose a new VERSION" >&2
                exit 1
              fi
              rm -rf artifacts
            '''
          }
        }

        stage('Prepare test environment') {
          steps {
            sh 'python3 -m venv .venv && .venv/bin/pip install -q -r tools/requirements.txt'
          }
        }

        stage('Validate immutable source lock') {
          steps { sh '.venv/bin/python tools/validate_source_lock.py "$SOURCE_LOCK_CONFIG" --require-mender' }
        }

        stage('Build Mender-capable image') {
          steps {
            sh '''
              export GIT_COMMIT="$(git rev-parse --short=7 HEAD)"
              scripts/build-image.sh
            '''
          }
        }

        stage('Test exact release disk in QEMU') {
          steps { sh 'scripts/run-release-qemu-tests.sh' }
        }

        stage('Collect SBOM') {
          steps { sh 'scripts/generate-sbom.sh' }
        }

        stage('Keep unsigned candidate') {
          steps {
            sh '''#!/bin/bash
              set -Eeuo pipefail
              artifact="$(find artifacts/deploy/qemuarm64 -maxdepth 1 -type f -name '*.mender' -print -quit)"
              test -n "$artifact"
              cp "$artifact" artifacts/unsigned-candidate.mender
              sha256sum artifacts/unsigned-candidate.mender > artifacts/unsigned-candidate.mender.sha256
            '''
            stash name: 'candidate', includes: 'artifacts/unsigned-candidate.mender*, artifacts/release-manifest.json, artifacts/sbom/**, artifacts/release-qemu/**'
          }
        }

        stage('Refresh cache') {
          steps {
            script {
              withEnv(['CACHE_WRITE_ALLOWED=1']) {
                if (env.MINIO_CACHE_CREDENTIALS_ID?.trim()) {
                  withCredentials([usernamePassword(credentialsId: env.MINIO_CACHE_CREDENTIALS_ID,
                                                    usernameVariable: 'MINIO_ACCESS_KEY',
                                                    passwordVariable: 'MINIO_SECRET_KEY')]) {
                    sh 'mc --no-color alias set "${MINIO_ALIAS:-tusker}" "${MINIO_ENDPOINT:-http://127.0.0.1:9000}" "$MINIO_ACCESS_KEY" "$MINIO_SECRET_KEY" >/dev/null'
                    sh 'scripts/cache-sync.sh push'
                  }
                } else {
                  sh 'scripts/cache-sync.sh push'
                }
              }
            }
          }
        }
      }
      post {
        always {
          junit testResults: 'artifacts/release-qemu/junit.xml', allowEmptyResults: true
          archiveArtifacts artifacts: 'artifacts/unsigned-candidate.mender*, artifacts/release-manifest.json, artifacts/sbom/**, artifacts/release-qemu/**',
                           allowEmptyArchive: true, fingerprint: true
        }
      }
    }

    // Nobody approves within 4 hours: the build ends ABORTED; the tested unsigned
    // candidate stays archived on the build, and a new run can sign it later.
    stage('Approve signing') {
      when { expression { params.SIGN_AND_PUBLISH != false } }
      options { timeout(time: 4, unit: 'HOURS') }
      steps {
        input message: "Sign and publish SensorNode ${params.VERSION} built from ${params.SOURCE_COMMIT}?",
              ok: 'Sign candidate',
              submitter: 'firmware-signing-approvers'
      }
    }

    // The stage timeout also covers waiting for the firmware-release agent, so a
    // missing or offline release agent fails the build instead of queueing forever.
    stage('Sign and publish') {
      when { expression { params.SIGN_AND_PUBLISH != false } }
      options { timeout(time: 30, unit: 'MINUTES') }
      agent { label 'firmware-release' }
      environment {
        SIGNING_KEY = '/var/lib/tusker-release/mender-signing.pem'
        MINIO_ALIAS = "${env.RELEASE_MINIO_ALIAS ?: 'tusker-release'}"
      }
      steps {
        sh 'rm -rf artifacts'
        unstash 'candidate'
        withEnv(['PATH+RELEASE=/var/lib/tusker-release/bin']) {
          sh '''#!/bin/bash
            set -Eeuo pipefail
            publish="artifacts/publish"
            name="sensornode-${VERSION}-${SOURCE_COMMIT}.mender"
            mkdir -p "$publish"
            cp artifacts/unsigned-candidate.mender "$publish/$name"
            [[ -f artifacts/release-manifest.json ]] && cp artifacts/release-manifest.json "$publish/"
            [[ -d artifacts/sbom ]] && cp -a artifacts/sbom "$publish/"
            [[ -d artifacts/release-qemu ]] && cp -a artifacts/release-qemu "$publish/"
            ARTIFACT="$publish/$name" scripts/sign-artifact.sh
            mender-artifact validate "$publish/$name" --key /var/lib/tusker-release/mender-verify.pem
            python3 tools/publish_candidate.py \
              --artifact-root "$publish" \
              --destination "minio://release-evidence/${VERSION}/${SOURCE_COMMIT}"

            # Everything sensornode-promote-mender needs, printed and archived.
            # Read the whole output first: an early exit in the reader would stop
            # mender-artifact with SIGPIPE (exit 141), which pipefail turns into a failure.
            artifact_info="$(mender-artifact read "$publish/$name" 2>/dev/null)"
            artifact_name="$(awk '$1 == "Name:" {print $2}' <<<"$artifact_info" | head -n 1)"
            [[ -n "$artifact_name" ]] || { echo "could not read the Mender artifact name" >&2; exit 1; }
            {
              echo "CANDIDATE_URI=minio://release-evidence/${VERSION}/${SOURCE_COMMIT}/${name}"
              echo "EXPECTED_SHA256=$(sha256sum "$publish/$name" | awk '{print $1}')"
              echo "ARTIFACT_NAME=${artifact_name}"
            } > artifacts/promotion-parameters.env
            echo "Parameters for sensornode-promote-mender:"
            cat artifacts/promotion-parameters.env
          '''
        }
        archiveArtifacts artifacts: 'artifacts/publish/*.mender.sha256, artifacts/promotion-parameters.env', fingerprint: true

        // Mark the released source in Git. The candidate is already published, so a
        // tag push failure leaves the build UNSTABLE rather than undoing a release;
        // rerunning scripts/push-release-tag.sh is safe.
        catchError(buildResult: 'UNSTABLE', stageResult: 'UNSTABLE',
                   message: "Release published, but tag v${params.VERSION} was not pushed to GitHub") {
          // 'github-release-tag' is a Secret file credential holding the deploy key.
          withCredentials([file(credentialsId: env.GITHUB_TAG_CREDENTIALS_ID ?: 'github-release-tag',
                                variable: 'TAG_PUSH_KEY_FILE')]) {
            withEnv(["TAG_REMOTE=${env.RELEASE_TAG_REMOTE ?: ''}"]) {
              sh '''#!/bin/bash
                set -Eeuo pipefail
                set -a; source artifacts/promotion-parameters.env; set +a
                # ssh refuses a key that others can read; use a private 0600 copy.
                key="$(umask 077 && mktemp)"
                trap 'rm -f "$key"' EXIT
                cp "$TAG_PUSH_KEY_FILE" "$key"
                export GIT_SSH_COMMAND="ssh -i $key -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new"
                scripts/push-release-tag.sh
              '''
            }
          }
        }
      }
    }
  }
}
