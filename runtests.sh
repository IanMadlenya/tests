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

declare -a repos=("augur-abi" "ethrpc" "keythereum" "augur.js" "augur-core")

echo -e "+${GRAY}==================${NC}+"
echo -e "${GRAY}| \033[1;35maugur${NC} test suite ${GRAY}|${NC}"
echo -e "+${GRAY}==================${NC}+\n"

if [ -f "${HERE}/tests.log" ]; then
    rm tests.log >>$HERE/tests.log 2>&1
fi

for repo in "${repos[@]}"
do
    url="https://github.com/AugurProject/${repo}"
    echo -e " - ${TEAL}${repo}${NC} ${GRAY}[${url}]${NC}"

    if [ -d "${HERE}/${repo}" ]; then
        rm -rf "${HERE}/${repo}" >>$HERE/tests.log 2>&1
    fi

    git clone "${url}" >>$HERE/tests.log 2>&1
    cd "${HERE}/${repo}"
    if [ "${repo}" == "augur-core" ]; then
        virtualenv venv >>$HERE/tests.log 2>&1
        source "${HERE}/${repo}/venv/bin/activate" >>$HERE/tests.log 2>&1
        pip install -r requirements-load.txt >>$HERE/tests.log 2>&1
    else
        npm install >>$HERE/tests.log 2>&1
    fi

    if [ "${repo}" == "augur.js" ]; then
        npm run testnet
    elif [ "${repo}" == "augur-core" ]; then
        python "${HERE}/${repo}/tests/test_load_contracts.py"
        deactivate >>$HERE/tests.log 2>&1
    else
        npm test -- -R progress
    fi

    cd "${HERE}"
    rm -rf "${HERE}/${repo}" >>$HERE/tests.log 2>&1
done
