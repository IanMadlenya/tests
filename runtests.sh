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

declare -a repos=("augur-core" "augur-abi" "keythereum" "ethrpc" "augur.js")

echo -e "+${GRAY}==================${NC}+"
echo -e "${GRAY}| \033[1;35maugur${NC} test suite ${GRAY}|${NC}"
echo -e "+${GRAY}==================${NC}+\n"

echo -e "${GREEN}Installing...${NC}"

for repo in "${repos[@]}"; do
    url="https://github.com/AugurProject/${repo}"
    echo -e " - ${TEAL}${repo}${NC} ${GRAY}[${url}]${NC}"
    if [ -f "${HERE}/tests.log" ]; then
        rm tests.log 2>&1
    fi
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
    cd "${HERE}"
done

echo -e "\n${GREEN}Running tests...${NC}\n"

for repo in "${repos[@]}"; do
    echo -e "${TEAL}${HERE}/${repo}${NC}"
    cd "${HERE}/${repo}"
    if [ "${repo}" == "augur.js" ]; then
        npm run testnet >>$HERE/tests.log 2>&1
    elif [ "${repo}" == "augur-core" ]; then
        python "${HERE}/${repo}/tests/test_load_contracts.py" >>$HERE/tests.log 2>&1
        deactivate >>$HERE/tests.log 2>&1
    else
        npm test -- -R progress >>$HERE/tests.log 2>&1
    fi
    cd "${HERE}"
    rm -rf "${HERE}/${repo}" >>$HERE/tests.log 2>&1
done
