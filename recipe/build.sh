#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --no-bin-links \
    --global \
    --build-from-source \
    rslib-core-${PKG_VERSION}.tgz

# Patch package.json to remove devDependencies which are not needed for license report
mv package.json package.json.bak
jq 'del(.devDependencies)' package.json.bak > package.json

# Create license report for dependencies
pnpm install
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

mkdir -p ${PREFIX}/bin
tee ${PREFIX}/bin/rslib << EOF
#!/bin/sh
exec \${CONDA_PREFIX}/lib/node_modules/@rslib/core/bin/rslib.js "\$@"
EOF
chmod +x ${PREFIX}/bin/rslib

# Create batch wrapper
tee ${PREFIX}/bin/rslib.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\lib\node_modules\@rslib\core\bin\rslib.js %*
EOF
