#!/bin/sh

PREFIX="@PREFIX@"

WRAPPER_EXE="$(basename "$0")"
# todo: error if called as wrapper.sh
# todo: fewer shell calls
COMPILER="$(cd "$(dirname "$0")" && basename "$(pwd)")"
COMPILER_VERSION="${COMPILER##*-}"
FILTER="$(cd "$(dirname "$(dirname "$0")")" && basename "$(pwd)")"

find_developer_dir () {
    if [ -x "$(which xcode-select 2>&1)" ]; then
        xcode-select -print-path
    else
        echo "/Developer"
    fi
}

find_developer_tool () {
    TOOL="$1"
    TOOL_PATH="/usr/bin/${TOOL}"
    if [ -x "${TOOL_PATH}" ]; then
        echo "${TOOL_PATH}"
    else
        TOOL_PATH="$(xcrun -find "${TOOL}" 2>/dev/null)"
        if [ -x "${TOOL_PATH}" ]; then
            echo "${TOOL_PATH}"
        else
            echo "$(find_developer_dir)/usr/bin/${TOOL}"
        fi
    fi
return
#old version:
    if [ ! -x "${TOOL_PATH}/${TOOL}" ]; then
        if [ -x "$(which xcrun 2>&1)" ]; then
            TOOL_PATH="$(dirname "$(xcrun -find "${TOOL}")")"
        fi
    fi
    if [ ! -x "${TOOL_PATH}/${TOOL}" ]; then
        TOOL_PATH="$(find_developer_dir)/usr/bin"
    fi
    echo "${TOOL_PATH}/${TOOL}"
}

case "${FILTER}" in
    -)
        FILTER_EXE=""
        ;;
    ccache-distcc)
        FILTER_EXE="ccache"
        export CCACHE_PREFIX="distcc"
        ;;
    *)
        FILTER_EXE="${FILTER}"
        ;;
esac

case "${COMPILER}" in
    *clang*)
        case "${WRAPPER_EXE}" in
            *++)
                REAL_EXE="clang++"
                ;;
            *)
                REAL_EXE="clang"
                ;;
        esac
        ;;
    *llvm-gcc*)
        case "${WRAPPER_EXE}" in
            *++)
                REAL_EXE="llvm-g++-${COMPILER_VERSION}"
                ;;
            *)
                REAL_EXE="llvm-gcc-${COMPILER_VERSION}"
                ;;
        esac
        ;;
    macports-gcc*)
        case "${WRAPPER_EXE}" in
            *++)
                REAL_EXE="g++-mp-${COMPILER_VERSION}"
                ;;
            *)
                REAL_EXE="gcc-mp-${COMPILER_VERSION}"
                ;;
        esac
        ;;
    *)
        case "${WRAPPER_EXE}" in
            *++)
                REAL_EXE="g++-${COMPILER_VERSION}"
                ;;
            *)
                REAL_EXE="gcc-${COMPILER_VERSION}"
                ;;
        esac
        ;;
esac

case "${COMPILER}" in
    macports-clang-*)
        REAL_EXE_PATH="${PREFIX}/libexec/llvm-${COMPILER_VERSION}/bin/${REAL_EXE}"
        ;;
    macports-*gcc*)
        REAL_EXE_PATH="${PREFIX}/bin/${REAL_EXE}"
        ;;
    *)
        REAL_EXE_PATH="$(find_developer_tool "${REAL_EXE}")"
        if [ "${REAL_EXE}" == "clang++" ]; then
            if [ ! -x "${REAL_EXE_PATH}" ]; then
                REAL_EXE_PATH="$(find_developer_tool "llvm-g++-4.2")"
            fi
        fi
        ;;
esac

# echo "Compiler collection: ${COMPILER}"
# echo "Compiler collection version: ${COMPILER_VERSION}"
# echo "Wrapper executable: ${WRAPPER_EXE}"
# echo "Filter: ${FILTER}"
# echo "Filter executable: ${FILTER_EXE}"
# echo "Real executable: ${REAL_EXE}"
# echo "Real executable path: ${REAL_EXE_PATH}"
# echo "Args:"
# 
# for ARG in "${@}"; do
#     echo "${ARG}"
# done

# echo \
exec ${FILTER_EXE} "${REAL_EXE_PATH}" "${@}" "-isystem${PREFIX}/include" "-L${PREFIX}/lib"
