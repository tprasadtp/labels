#!/bin/sh
set -eo pipefail
# Labels sync Action
if [ -z "${INPUT_OWNER}" ] || [ -z "${INPUT_REPO}" ]; then
    echo "Parse owner and repo names from var GITHUB_REPOSITORY : ${GITHUB_REPOSITORY}"
    export INPUT_OWNER="$(echo "$GITHUB_REPOSITORY" | cut -d '/' -f1)"
    export INPUT_REPO="$(echo "$GITHUB_REPOSITORY" | cut -d '/' -f2)"
    echo "Set OWNER as ${INPUT_OWNER} and repo as ${INPUT_REPO}"
else
    echo "Both OWNER and repo have been defined!"
    echo "OWNER as ${INPUT_OWNER} and repo as ${INPUT_REPO}"
fi

echo "INPUT_FILE specified is ${INPUT_FILE}"

if [ "${INPUT_AUTOFETCH}" == "true" ]; then
    echo "Autofetching URL https://raw.githubusercontent.com/${INPUT_OWNER}/${INPUT_REPO}/${GITHUB_SHA}/${INPUT_FILE}"
    base_dir="$(dirname "${INPUT_FILE}")"
    mkdir -p "${base_dir}"
    curl -sSfL -H "Authorization: token ${INPUT_TOKEN}" "https://raw.githubusercontent.com/${INPUT_OWNER}/${INPUT_REPO}/${GITHUB_SHA}/${INPUT_FILE}" -o "${INPUT_FILE}"
fi

echo "Running Labels Sync"
labels -v sync
