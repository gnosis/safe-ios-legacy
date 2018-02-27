#! /usr/bin/env bash

if [ "$CI" = "true" ]; then
    exit 0;
elif which swiftgen >/dev/null; then
    swiftgen config run --config safe/swiftgen.yml
else
    echo "warning: SwiftGen not installed, download from https://github.com/SwiftGen/SwiftGen"
fi
