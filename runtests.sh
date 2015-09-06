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

declare -a repos=("augur-abi" "keythereum" "ethrpc" "augur.js")

echo -e "+${GRAY}==================${NC}+"
echo -e "${GRAY}| \033[1;35maugur${NC} test suite ${GRAY}|${NC}"
echo -e "+${GRAY}==================${NC}+\n"

echo -e "${GREEN}Installing...${NC}"

for repo in "${repos[@]}"; do
    url="https://github.com/AugurProject/${repo}"
    echo -e " - ${TEAL}${repo}${NC} ${GRAY}[${url}]${NC}"
    if [ -d "${HERE}/${repo}" ]; then
        rm -rf "${HERE}/${repo}" >>$HERE/tests.log 2>&1
    fi
    git clone "${url}" >>$HERE/tests.log 2>&1
    cd "${HERE}/${repo}"
    npm install >>$HERE/tests.log 2>&1
    cd "${HERE}"
done

echo -e "\n${GREEN}Running tests...${NC}\n"

for repo in "${repos[@]}"; do
    echo -e "${TEAL}${HERE}/${repo}${NC}"
    cd "${HERE}/${repo}"
    npm test -- -R progress
    cd "${HERE}"
    rm -rf "${HERE}/${repo}" >>$HERE/tests.log 2>&1
done
