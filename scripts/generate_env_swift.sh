ENV_VARS=${SCRIPT_INPUT_FILE_0}

# if file ${ENV_VARS} exist
if [ -e ${ENV_VARS} ]; then
# then load all variables from that file to memory
    source ${ENV_VARS}
fi

# if INFURA_API_KEY does not exist
if [ -z ${INFURA_API_KEY+x} ]; then
    # get path to this script's file
    SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
    # print Xcode error
    echo "$0:6:1: error: Missing INFURA_API_KEY environment variable." >&2
    exit 1 # exit with failure
else
# else generate Keys file:
# create enclosing dir if needed
    DIR=$(dirname "${SCRIPT_OUTPUT_FILE_0}")
    mkdir -p $DIR
# write template contents to file
    cat << EOF > ${SCRIPT_OUTPUT_FILE_0}
// Auto-gencerated file, don't modify it by hand.
// swiftlint:disable all

struct Keys {
    static let infuraApiKey = "${INFURA_API_KEY}"
}
EOF
    echo "Generated ${SCRIPT_OUTPUT_FILE_0}"
fi
