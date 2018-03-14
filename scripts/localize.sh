#! /usr/bin/env bash

set -ex
MERGE_SCRIPT=${SRCROOT}/../scripts/merge_strings.rb
TEMP_FILE=Localizable.strings
find ${SRCROOT} -name "*.swift" -and -not -name "NSLocalizedString.swift" | xargs genstrings -o .
iconv -f utf-16 -t utf-8 $TEMP_FILE > "${TEMP_FILE}.utf8"
mv "${TEMP_FILE}.utf8" $TEMP_FILE
if [ ! -e $TEMP_FILE ]; then
    exit 0
fi
find ${SRCROOT} -name "Localizable.strings" -print0 | xargs -0 -I STRINGS_FILE $MERGE_SCRIPT $TEMP_FILE STRINGS_FILE
rm $TEMP_FILE
