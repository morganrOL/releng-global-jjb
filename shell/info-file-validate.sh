#!/bin/bash
# SPDX-License-Identifier: EPL-1.0
##############################################################################
# Copyright (c) 2018 The Linux Foundation and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
##############################################################################
echo '--> info-file-validate.sh'
set -e -o pipefail
set -x  # Enable trace

virtualenv --quiet "/tmp/v/info"
# shellcheck source=/tmp/v/info/bin/activate disable=SC1091
source "/tmp/v/info/bin/activate"
pip install PyYAML jsonschema rfc3987 yamllint

# Download info-schema.yaml and yaml-verfy-schema.py
wget -q https://raw.githubusercontent.com/lfit/releng-global-jjb/master/schema/info-schema.yaml \
https://raw.githubusercontent.com/lfit/releng-global-jjb/master/yaml-verify-schema.py

yamllint INFO.yaml

python yaml-verify-schema.py \
    -s info-schema.yaml \
    -y INFO.yaml
