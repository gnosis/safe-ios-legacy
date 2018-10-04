#!/bin/sh
set -ex

mkdir -p "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"

install_framework()
{
  if [ -r "${BUILT_PRODUCTS_DIR}/$1" ]; then
    local source="${BUILT_PRODUCTS_DIR}/$1"
  elif [ -r "${BUILT_PRODUCTS_DIR}/$(basename "$1")" ]; then
    local source="${BUILT_PRODUCTS_DIR}/$(basename "$1")"
  elif [ -r "$1" ]; then
    local source="$1"
  fi

  local destination="${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"

  if [ -L "${source}" ]; then
      source="$(readlink "${source}")"
  fi

  # use filter instead of exclude so missing patterns dont' throw errors
  rsync -av --ignore-existing --filter "- CVS/" --filter "- .svn/" --filter "- .git/" --filter "- .hg/" --filter "- Headers" --filter "- PrivateHeaders" --filter "- Modules" "${source}" "${destination}"

  # Resign the code if required by the build settings to avoid unstable apps
  code_sign_if_enabled "${destination}/$(basename "$1")"
}

# Signs a framework with the provided identity
code_sign_if_enabled() {
  if [ -n "${EXPANDED_CODE_SIGN_IDENTITY}" -a "${CODE_SIGNING_REQUIRED}" != "NO" -a "${CODE_SIGNING_ALLOWED}" != "NO" ]; then
    /usr/bin/codesign --force --sign ${EXPANDED_CODE_SIGN_IDENTITY} --preserve-metadata=identifier,entitlements "$1"
  fi
}



embed_framework() {
  LIBRARY_FOLDER="${SRCROOT}/../Library/${PLATFORM_NAME}"
  framework=$(basename "$1")
  dsym=${framework}.dSYM
  install_framework "${LIBRARY_FOLDER}/$framework"
  rsync -av --ignore-existing "${LIBRARY_FOLDER}/${dsym}/" "${BUILT_PRODUCTS_DIR}/${dsym}"
}

for (( n = 0; n < SCRIPT_INPUT_FILE_COUNT; n++ )); do
    VAR=SCRIPT_INPUT_FILE_$n
    filename="${!VAR}"
    embed_framework $filename
done

for (( n = 0; n < SCRIPT_INPUT_FILE_LIST_COUNT; n++ )); do
    VAR=SCRIPT_INPUT_FILE_LIST_$n
    list=$(cat "${!VAR}")
    for filename in $list; do
      embed_framework $filename
    done
done

