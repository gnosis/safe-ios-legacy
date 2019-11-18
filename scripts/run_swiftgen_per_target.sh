#! /usr/bin/env bash

set -ex

if [ "$CI" = "true" ]; then
    exit 0;
elif which swiftgen >/dev/null; then
    cd "${SRCROOT}/${PRODUCT_NAME}/"
    swiftgen --version
    swiftgen config run --config "swiftgen.yml"
else
    echo "warning: SwiftGen not installed, download from https://github.com/SwiftGen/SwiftGen"
fi
