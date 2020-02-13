#!/bin/sh
set -eo pipefail

echo "INPUT_FILE specified is ${INPUT_FILE}"


function fetch_labels_file()
{
    local repo_slug="${1}"
    if [ "${INPUT_AUTOFETCH}" == "true" ]; then
        echo "Autofetching URL https://raw.githubusercontent.com/${repo_slug}/${GITHUB_SHA}/${INPUT_FILE}"
        base_dir="$(dirname "${INPUT_FILE}")"
        mkdir -p "${base_dir}"
        curl -sSfL -H "Authorization: token ${INPUT_TOKEN}" "https://raw.githubusercontent.com/${INPUT_OWNER}/${INPUT_REPO}/${GITHUB_SHA}/${INPUT_FILE}" -o "${INPUT_FILE}"
    else
        echo "Autofetch is not enabled!"
    fi
}

# Labels sync Action
if [ -z "${INPUT_OWNER}" ] || [ -z "${INPUT_REPO}" ]; then
    echo "GITHUB_REPOSITORY : ${GITHUB_REPOSITORY}"
    fetch_labels_file "${GITHUB_REPOSITORY}"
    echo "Running Labels Sync"

    labels -v -t "${INPUT_TOKEN}" sync -f "${INPUT_FILE}"
else
    echo "Custom OWNER and REPO have been defined!"
    echo "OWNER as ${INPUT_OWNER} and repo as ${INPUT_REPO}"
    fetch_labels_file "${INPUT_OWNER}/${INPUT_REPO}"

    echo "Running Labels Sync"
    labels -v -t "${INPUT_TOKEN}" sync -o "${INPUT_OWNER}" -r "${INPUT_REPO}" -f "${INPUT_FILE}"
fi
