#! /usr/bin/env bash

# exit immediately if any command in this bash script fails
set -e

# Arguments are project directories where to search for Localizable.strings
SOURCE_DIR_LIST="$@"

# stackoverflow  https://stackoverflow.com/questions/59895/get-the-source-directory-of-a-bash-script-from-within-the-script-itself
# get the current dir of the script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TRANSLATE="${DIR}/translate_strings.rb"

# create a temporary directory to hold new translations
TRANSLATIONS_DIR=`mktemp -d /tmp/safe-ios-translations.XXXXX`

echo "Downloading translation files..."

scripts/lokalise --token ${LOKALISE_TOKEN}  export ${LOKALISE_PROJECT_ID} --type strings --unzip_to ${TRANSLATIONS_DIR} --include_comments 1

echo "Translating..."

# For each translated file we downloaded, find all Localizable.strings in the source 
# code and update it with the translations we downloaded.
for TRANSLATED_FILE in `find ${TRANSLATIONS_DIR} -name "Localizable.strings"`; do
    # search for localizable strings with the same path ending (XX.lproj/Localizable.strings)
    LOCALE=$(basename $(dirname ${TRANSLATED_FILE}) .lproj)
    printf "Locale ${LOCALE}..."

    # translate each file found in the sources directories
    find ${SOURCE_DIR_LIST} -path "*/${LOCALE}.lproj/Localizable.strings" \
        -and -not -path "*.bundle/*" \
        -and -not -path "*.framework/*" -print0 | \
        xargs -0 -I EXISTING_STRINGS ${TRANSLATE} EXISTING_STRINGS ${TRANSLATED_FILE}
    printf " done\n"
done

echo "Removing temp files"
rm -rf ${TRANSLATIONS_DIR}

echo "Done"
