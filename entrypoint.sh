#!/bin/sh
set -eo pipefail

if [ "${INPUT_AUTOFETCH}" == "true" ]; then
    echo "Autofetching URL https://raw.githubusercontent.com/${INPUT_OWNER}/${INPUT_REPO}/${GITHUB_SHA}/${INPUT_FILE}"
    base_dir="$(dirname "${INPUT_FILE}")"
    mkdir -p "${base_dir}"
    curl -sSfL -H "Authorization: token ${INPUT_TOKEN}" "https://raw.githubusercontent.com/${INPUT_OWNER}/${INPUT_REPO}/${GITHUB_SHA}/${INPUT_FILE}" -o "${INPUT_FILE}"
fi

echo "INPUT_FILE specified is ${INPUT_FILE}"

# Labels sync Action
if [ -z "${INPUT_OWNER}" ] || [ -z "${INPUT_REPO}" ]; then
    echo "GITHUB_REPOSITORY : ${GITHUB_REPOSITORY}"
    echo "Running Labels Sync"
    labels -v sync -f "${INPUT_FILE}"
else
    echo "Custon OWNER and REPO have been defined!"
    echo "OWNER as ${INPUT_OWNER} and repo as ${INPUT_REPO}"
    labels -v sync -o "${INPUT_OWNER}" -r "${INPUT_REPO}" -f "${INPUT_FILE}"
fi
