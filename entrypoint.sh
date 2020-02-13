#!/bin/sh
# shellcheck disable=SC2039
set -eo pipefail

# Labels sync Action
if [ -z "${INPUT_OWNER}" ]; then
    echo "Parse owner from GITHUB_REPOSITORY : ${GITHUB_REPOSITORY}"
    INPUT_OWNER="$(echo "$GITHUB_REPOSITORY" | cut -d '/' -f1)"
fi

if [ -z "${INPUT_REPO}" ]; then
    echo "Parse repo from GITHUB_REPOSITORY : ${GITHUB_REPOSITORY}"
    INPUT_REPO="$(echo "$GITHUB_REPOSITORY" | cut -d '/' -f2)"
fi

# Info
echo "OWNER is set as ${INPUT_OWNER} and repo as ${INPUT_REPO}"

# shellcheck disable=SC2039
if [ "${INPUT_AUTOFETCH}" == "true" ]; then
    echo "Autofetching URL https://raw.githubusercontent.com/${INPUT_OWNER}/${INPUT_REPO}/${GITHUB_SHA}/${INPUT_FILE}"
    base_dir="$(dirname "${INPUT_FILE}")"
    mkdir -p "${base_dir}"
    curl -sSfL -H "Authorization: token ${INPUT_TOKEN}" "https://raw.githubusercontent.com/${INPUT_OWNER}/${INPUT_REPO}/${GITHUB_SHA}/${INPUT_FILE}" -o "${INPUT_FILE}"
else
    echo "Autofetch is not enabled!"
fi

echo "Running Labels Sync"
labels -v -t "${INPUT_TOKEN}" sync -o "${INPUT_OWNER}" -r "${INPUT_REPO}" -f "${INPUT_FILE}"
