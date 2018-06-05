#! /usr/bin/env bash
set -ex
VERS=$(cd safe; agvtool mvers -terse1; cd ..)
bundle exec jazzy --module-version $VERS --module Common --output docs/html/Common --xcodebuild-arguments -workspace,safe.xcworkspace,-scheme,Common --readme Common/Common/README.md
