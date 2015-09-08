#!/bin/bash
# Augur test runner.
# @author Jack Peterson (jack@tinybike.net)

set -e
trap "exit" INT

TEAL='\033[0;36m'
GREEN='\033[0;32m'
GRAY='\033[1;30m'
NC='\033[0m'

HERE=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
LOG="${HERE}/tests.log"

declare -a repos=("augur-abi" "ethrpc" "keythereum" "augur.js")

echo -e "+${GRAY}==================${NC}+"
echo -e "${GRAY}| \033[1;35maugur${NC} test suite ${GRAY}|${NC}"
echo -e "+${GRAY}==================${NC}+\n"

# delete log file
if [ -f "${HERE}/tests.log" ]; then
    rm "${HERE}/tests.log" >>"${LOG}" 2>&1
fi

for repo in "${repos[@]}"
do
    fullpath="${HERE}/${repo}"
    url="https://github.com/AugurProject/${repo}"
    echo -e "${TEAL}${repo}${NC} ${GRAY}[${url}]${NC}"

    # remove existing directory
    if [ -d "${fullpath}" ]; then
        rm -rf "${fullpath}" >>"${LOG}" 2>&1
    fi

    # clone and install repo
    git clone "${url}" "${fullpath}" >>"${LOG}" 2>&1
    cd "${fullpath}"
    if [ "${repo}" == "augur-core" ]; then
        virtualenv venv >>"${LOG}" 2>&1
        source "${fullpath}/venv/bin/activate" >>"${LOG}" 2>&1
        pip install -r requirements-load.txt >>"${LOG}" 2>&1
    else
        npm install >>"${LOG}" 2>&1
    fi

    # run unit tests
    if [ "${repo}" == "augur.js" ]; then
        npm run testnet
    elif [ "${repo}" == "augur-core" ]; then
        python "${fullpath}/tests/test_load_contracts.py"
        deactivate >>"${LOG}" 2>&1
    else
        npm test -- -R progress
    fi

    # clean up
    cd "${HERE}"
    rm -rf "${fullpath}" >>"${LOG}" 2>&1
done
