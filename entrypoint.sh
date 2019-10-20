#!/bin/sh
labels -u "${INPUT_OWNER}" -t "${INPUT_TOKEN}" sync -r "${INPUT_REPO}" -o "${INPUT_OWNER}" -f "${GITHUB_WORKSPACE}/.github/labels.toml"