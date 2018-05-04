#! /usr/bin/env bash

if which swiftlint >/dev/null; then
    cd "${SRCROOT}/${PRODUCT_NAME}"
    swiftlint --config "swiftlint.yml"
else
    echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi
