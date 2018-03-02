#! /usr/bin/env bash

if which swiftlint >/dev/null; then
    cd ..; swiftlint
else
    echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi
