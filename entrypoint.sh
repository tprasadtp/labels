#!/bin/sh
# Labels sync Action
if [ -z "${INPUT_OWNER}" ] || [ -z "${INPUT_REPO}" ]; then
    echo "Parse owner and repo names from var GITHUB_REPOSITORY : ${GITHUB_REPOSITORY}"
    INPUT_OWNER="$(echo "$GITHUB_REPOSITORY" | cut -d '/' -f1)"
    INPUT_REPO="$(echo "$GITHUB_REPOSITORY" | cut -d '/' -f2)"
    echo "Set OWNER as ${INPUT_OWNER} and repo as ${INPUT_REPO}"
else
    echo "Both OWNER and repo have been defined!"
    echo "OWNER as ${INPUT_OWNER} and repo as ${INPUT_REPO}"
fi

if [ -z "${INPUT_FILE}" ]; then
    INPUT_FILE=".github/labels.toml"
    echo "INPUT_FILE will default to ${INPUT_FILE}"
else
    echo "INPUT_FILE specified is ${INPUT_FILE}"
fi

echo "Running Labels Sync"
labels -v -u "${INPUT_OWNER}" -t "${INPUT_TOKEN}" sync -r "${INPUT_REPO}" -o "${INPUT_OWNER}" -f "${GITHUB_WORKSPACE}/${INPUT_FILE}"
