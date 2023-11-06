#!/usr/bin/env bash
# set -x
set -eou pipefail
cur="${ACCOUNT_PATH:-$1}"

get_list () {
    repo_home=$(pwd)
    while [[ "$cur" != "$repo_home" && "$cur" != "/" ]];
    do
        rel=$(find "$cur" -maxdepth 1 -mindepth 1 -name terraform.tfvars)
        if [[ "$rel" != "" ]]; then
            echo "${rel#$repo_home}"
        fi
        cur="$(realpath "${cur}"/../)"
    done
}

for varfile in $(get_list | tac); do
    echo -n "-var-file=/opt/app/${varfile#/} "
done
