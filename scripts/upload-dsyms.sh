#! /usr/bin/env bash

set -ex

if [ ${CONFIGURATION} != "Debug" ]; then
  find ${BUILT_PRODUCTS_DIR} -name "*.dSYM" | \
    xargs -I \{\} ${SRCROOT}/../scripts/fabric-upload-symbols \
    -a ${CRASHLYTICS_API_TOKEN} -p ios \{\}
fi

