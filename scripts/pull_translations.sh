#! /usr/bin/env bash

# exit immediately if any command in this bash script fails
set -e

# Arguments are project directories where to search for Localizable.strings
SOURCE_DIR_LIST="$@"

# stackoverflow  https://stackoverflow.com/questions/59895/get-the-source-directory-of-a-bash-script-from-within-the-script-itself
# get the current dir of the script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TRANSLATE="${DIR}/translate_strings.rb"
LINT_LOCALIZATIONS="${DIR}/lint_localizations.rb"

# create a temporary directory to hold new translations
TRANSLATIONS_DIR=`mktemp -d /tmp/safe-ios-translations.XXXXX`
# temp directory where linter results are stored
LINT_OUT_DIR=`mktemp -d /tmp/safe-ios-translations-lint.XXXXX`

echo "Downloading translation files..."

scripts/lokalise --token ${LOKALISE_TOKEN}  export ${LOKALISE_PROJECT_ID} --type strings --unzip_to ${TRANSLATIONS_DIR} --include_comments 1

echo "Translating..."

# here is the flag to check if we got warnings,
# because we want to keep the temp lint dir if there were any warnings
HAS_LINT_OUTPUT="NO"

# For each translated file we downloaded, find all Localizable.strings in the source 
# code and update it with the translations we downloaded.
for TRANSLATED_FILE in `find ${TRANSLATIONS_DIR} -name "Localizable.strings"`; do
    # search for localizable strings with the same path ending (XX.lproj/Localizable.strings)
    LOCALE=$(basename $(dirname ${TRANSLATED_FILE}) .lproj)
    echo "Locale ${LOCALE}..."

    # translate each file found in the sources directories
    find ${SOURCE_DIR_LIST} -path "*/${LOCALE}.lproj/Localizable.strings" \
        -and -not -path "*.bundle/*" \
        -and -not -path "*.framework/*" -print0 | \
        xargs -0 -I EXISTING_STRINGS ${TRANSLATE} EXISTING_STRINGS ${TRANSLATED_FILE}
    
    echo "Linting..."

    # merge all Localizable.strings files into one temporary .strings file
    TEMP_STRINGS=`mktemp /tmp/safe-ios-${LOCALE}-Localizable.strings.XXXXX`

    find ${SOURCE_DIR_LIST} -path "*/${LOCALE}.lproj/Localizable.strings" \
        -and -not -path "*.bundle/*" \
        -and -not -path "*.framework/*" \
        -exec cat \{\} \; \
        > ${TEMP_STRINGS}

    # Lint the merged file and save the output in the log file
    LINT_LOG="${LINT_OUT_DIR}/${LOCALE}.txt"
    ${LINT_LOCALIZATIONS} ${TEMP_STRINGS} ${TRANSLATED_FILE} > ${LINT_LOG}
    
    # if log file is not empty, then we mention it, otherwise remove it
    if [ -s ${LINT_LOG} ]; then
        echo "[WARNING]: Lint violations stored in ${LINT_LOG}"
        HAS_LINT_OUTPUT="YES"
    else 
        rm -rf ${LINT_LOG}
    fi

    # remove temporary merged file
    rm -rf ${TEMP_STRINGS}
done

echo "Removing temp files"
rm -rf ${TRANSLATIONS_DIR}

if [ "${HAS_LINT_OUTPUT}" == "NO" ]; then
  rm -rf ${LINT_OUT_DIR}
else 
    echo "[WARNING]: Lint output stored in ${LINT_OUT_DIR}"
fi

echo "Done"
