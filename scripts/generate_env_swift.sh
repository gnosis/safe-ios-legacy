ENV_VARS=${SCRIPT_INPUT_FILE_0}
if [ -e ${ENV_VARS} ]; then
# load all variables to bash from the file
    source ${ENV_VARS}
fi

# if INFURA_API_KEY does not exist
if [ -z ${INFURA_API_KEY+x} ]; then
    SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
    echo "$0:6:1: error: Missing INFURA_API_KEY environment variable." >&2
    exit 1
else
# create enclosing dir if needed
    DIR=$(dirname "${SCRIPT_OUTPUT_FILE_0}")
    mkdir -p $DIR
# write contents to file
    cat << SWIFT_FILE > ${SCRIPT_OUTPUT_FILE_0}
// Auto-gencerated file, don't modify it by hand.
// swiftlint:disable all

struct Keys {
    static let infuraApiKey = "${INFURA_API_KEY}"
}
SWIFT_FILE
    echo "Generated ${SCRIPT_OUTPUT_FILE_0}"
fi
