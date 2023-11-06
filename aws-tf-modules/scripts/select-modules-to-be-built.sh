#!/usr/bin/env bash

set -euo pipefail

# set from the environment if possible
MODULES=${MODULES:-}

function select_by_git_modification() {
    # we can't just run `git branch` because checkouts have detached heads on BuildKite
  branch=$(git branch --all --contains HEAD | tail -n1 | sed -e 's!remotes/origin/!!' | tr -d ' ' | tr -d '*' | tr -d '\n')

  files=""

  # HEAD == master because on BK we use detached heads
  if [[ "$branch" == "master" ]]; then
    files=$(git diff --name-only HEAD~1 2>&1)
  else
    first_commit=$(git cherry -v master | head -n1 | cut -d ' ' -f2 | tr -d '\n' || true)
    if [[ "$first_commit" != "" ]]; then
      files=$(git diff --name-only "$first_commit"^.. 2>&1)
    fi
  fi

  modules=$(echo "$files" | grep '^modules/' || true)

  if [[ -n "$modules" ]]; then
    modules=$(echo "$modules" | cut -d '/' -f 2 | uniq)
  else
    # use a default so Buildkite doesn't complain
    modules="eks-epaas"
  fi

  for module in $modules; do
    if [[ -d "modules/$module" ]]; then
        MODULES+="$module "
    fi
  done
}

if [ -n "$MODULES" ]; then
  if [ "$MODULES" = "all" ] || [ "$MODULES" = "ALL" ]; then
    echo "Will rebuild all modules" >&2
    MODULES=$(find modules/ -maxdepth 1 -mindepth 1 -type d | sort -n | xargs basename -a | tr '\n' ' ')
  else
    echo "Using given list of modules to build: $MODULES" >&2
  fi
else
  ALL=""
  ALL=$(git log -1 --pretty=%B | grep '\[build all\]' >/dev/null && echo all || echo "default")
  if [ "$ALL" = "all" ]; then
    echo "Will rebuild all modules (because of commit message '[build all]'" >&2
    MODULES=$(find modules/ -maxdepth 1 -mindepth 1 -type d | sort -n | xargs basename -a | tr '\n' ' ')
  else
    echo "Inspecting git repo for modified modules to build..." >&2
    select_by_git_modification
  fi
fi

# Remove module-template and test-module from MODULES
MODULES=${MODULES/module-template /}
MODULES=${MODULES/test-module /}

echo "$MODULES"