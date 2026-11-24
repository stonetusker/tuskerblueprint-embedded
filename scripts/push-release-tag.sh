#!/usr/bin/env bash
# Tag a signed, published release candidate in Git and push the tag to GitHub.
#
# Runs on the firmware-release agent at the end of sensornode-release-candidate,
# only after the candidate is signed and written to MinIO. The tag is annotated,
# points at the exact SOURCE_COMMIT that was built, and records where the signed
# artifact lives. When TAG_SIGNING_KEY exists the tag is SSH-signed as well.
#
# Idempotent: if v$VERSION already exists on the remote at SOURCE_COMMIT this is
# a no-op; if it exists at any other commit the script fails and changes nothing.
#
# Inputs: VERSION, SOURCE_COMMIT, CANDIDATE_URI, EXPECTED_SHA256,
#         TAG_REMOTE (push URL, default: origin's URL), TAG_SIGNING_KEY (optional),
#         GIT_SSH_COMMAND (set by the pipeline to use the tag-push deploy key).
set -Eeuo pipefail
source "$(dirname "$0")/lib/common.sh"

VERSION="${VERSION:-}"
SOURCE_COMMIT="${SOURCE_COMMIT:-}"
CANDIDATE_URI="${CANDIDATE_URI:-}"
EXPECTED_SHA256="${EXPECTED_SHA256:-}"
TAG_SIGNING_KEY="${TAG_SIGNING_KEY:-/var/lib/tusker-release/git-tag-signing.key}"

[[ -n "$VERSION" && -n "$SOURCE_COMMIT" ]] || die "VERSION and SOURCE_COMMIT are required"
[[ "$SOURCE_COMMIT" =~ ^[0-9a-f]{40}$ ]] || die "SOURCE_COMMIT must be a full 40-character commit"
require_command git

tag="v${VERSION}"
remote="${TAG_REMOTE:-$(git remote get-url origin)}"

existing="$(git ls-remote --tags "$remote" "refs/tags/${tag}^{}" "refs/tags/${tag}" \
            | awk '{print $1}' | tail -n 1)"
if [[ -n "$existing" ]]; then
    # For an annotated tag, "^{}" (listed last) is the commit it points at.
    [[ "$existing" == "$SOURCE_COMMIT" ]] \
        || die "$tag already exists on the remote at $existing, not $SOURCE_COMMIT; refusing to move a release tag"
    info "$tag already on the remote at $SOURCE_COMMIT; nothing to do"
    exit 0
fi

git fetch --quiet origin '+refs/heads/main:refs/remotes/origin/main'
git cat-file -e "${SOURCE_COMMIT}^{commit}" || die "$SOURCE_COMMIT is not available locally"
git merge-base --is-ancestor "$SOURCE_COMMIT" origin/main || die "$SOURCE_COMMIT is not on main"

message="SensorNode ${VERSION}

Source commit: ${SOURCE_COMMIT}
Signed artifact: ${CANDIDATE_URI:-unknown}
Artifact sha256: ${EXPECTED_SHA256:-unknown}
Jenkins build: ${BUILD_URL:-${BUILD_NUMBER:-unknown}}"

git_id=(-c user.name="SensorNode Release" -c user.email="release@sensornode.invalid")
if [[ -r "$TAG_SIGNING_KEY" ]]; then
    git "${git_id[@]}" -c gpg.format=ssh -c user.signingkey="$TAG_SIGNING_KEY" \
        tag --sign --force -m "$message" "$tag" "$SOURCE_COMMIT"
    info "created SSH-signed tag $tag"
else
    warn "no tag signing key at $TAG_SIGNING_KEY; creating an unsigned annotated tag"
    git "${git_id[@]}" tag --annotate --force -m "$message" "$tag" "$SOURCE_COMMIT"
fi

# Push only the tag ref, never a branch.
git push "$remote" "refs/tags/${tag}:refs/tags/${tag}"
info "pushed $tag -> $SOURCE_COMMIT"
