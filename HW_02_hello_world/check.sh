#!/bin/bash

set -e

MODULE_NAME="my_module"
PARAMS_DIR="/sys/module/${MODULE_NAME}/parameters"
EXPECTED="Hello, World!"

if [ ! -d "$PARAMS_DIR" ]; then
    echo "ERROR: module ${MODULE_NAME} is not loaded"
    exit 1
fi

for param in idx ch_val my_str; do
    if [ ! -e "${PARAMS_DIR}/${param}" ]; then
        echo "ERROR: parameter ${param} not found"
        exit 1
    fi
done

for ((i = 0; i < ${#EXPECTED}; i++)); do
    char="${EXPECTED:i:1}"
    ascii=$(printf '%d' "'$char")

    echo "$i" > "${PARAMS_DIR}/idx"
    echo "$ascii" > "${PARAMS_DIR}/ch_val"
done

actual=$(cat "${PARAMS_DIR}/my_str")
if [ "$actual" != "$EXPECTED" ]; then
    echo "ERROR: expected '${EXPECTED}', got '${actual}'"
    exit 1
fi

if sh -c "echo \"$EXPECTED\" > \"$PARAMS_DIR/my_str\"" 2>/dev/null; then
    echo "ERROR: my_str is writable"
    exit 1
fi

echo "OK: ${actual}"
