#!/bin/bash -l
# SPDX-License-Identifier: EPL-1.0
##############################################################################
# Copyright (c) 2017 The Linux Foundation and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
##############################################################################
echo "---> tox-run.sh"

# Ensure we fail the job if any steps fail.
# DO NOT set -u as virtualenv's activate script has unbound variables
set -e -o pipefail

ARCHIVE_TOX_DIR="$WORKSPACE/archives/tox"
mkdir -p "$ARCHIVE_TOX_DIR"
cd "$WORKSPACE/$TOX_DIR"

if [ -d "/opt/pyenv" ]; then
    echo "---> Setting up pyenv"
    export PYENV_ROOT="/opt/pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
fi

# Set and pass in PYTHONPATH to circumvent installation bug in tox>=3.2.0
PYTHONPATH=$(pwd)
export PYTHONPATH
export TOX_TESTENV_PASSENV=PYTHONPATH

set +e  # Allow detox to fail so that we can collect the logs in the next step

PARALLEL="${PARALLEL:-true}"
if [ "${PARALLEL}" = true ]; then
    if [ -n "$TOX_ENVS" ]; then
        tox -e "$TOX_ENVS" --parallel auto --parallel-live | tee -a "$ARCHIVE_TOX_DIR/tox.log"
        tox_status="${PIPESTATUS[0]}"
    else
        tox --parallel auto --parallel-live | tee -a "$ARCHIVE_TOX_DIR/tox.log"
        tox_status="${PIPESTATUS[0]}"
    fi
else
    if [ -n "$TOX_ENVS" ]; then
        tox -e "$TOX_ENVS" | tee -a "$ARCHIVE_TOX_DIR/tox.log"
        tox_status="${PIPESTATUS[0]}"
    else
        tox | tee -a "$ARCHIVE_TOX_DIR/tox.log"
        tox_status="${PIPESTATUS[0]}"
    fi
fi

# Disable SC2116 as we want to echo a space separated list of TOX_ENVS
# shellcheck disable=SC2116
for i in .tox/*/log; do
    tox_env=$(echo "$i" | awk -F'/' '{print $2}')
    cp -r "$i" "$ARCHIVE_TOX_DIR/$tox_env"
done
set -e  # Logs collected so re-enable

echo "Completed tox runs."

test "$tox_status" -eq 0 || exit "$tox_status"
