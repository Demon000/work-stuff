#!/bin/bash

POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
	case $1 in
	-d|--dtbs)
		DTBS=1
		shift
		;;
	-m|--modules)
		MODULES_PATH="$2"
		shift
		shift
		;;
	-h|--headers)
		HEADERS_PATH="$2"
		shift
		shift
		;;
	-*|--*)
		echo "Unknown option $1"
		exit 1
		;;
	*)
		POSITIONAL_ARGS+=("$1")
		shift
		;;
	esac
done

set -- "${POSITIONAL_ARGS[@]}"

print_usage() {
	echo "usage: $0 <rpi|rpi64> [target]"
	exit 1
}

if [[ $# -lt 1 ]]; then
	print_usage
fi

BOARD_TYPE="$1"
TARGET="$2"
TARGETS=()

if [[ -z "$TARGET" ]]; then
	if [[ "$BOARD_TYPE" = "rpi" ]]; then
		TARGETS+=("zImage")
	elif [[ "$BOARD_TYPE" = "rpi64" ]]; then
		TARGETS+=("Image")
	fi
fi

if [[ -n "$MODULES_PATH" ]]; then
	TARGETS+=("modules")
fi

if [[ -n "$DTBS" ]]; then
	TARGETS+=("dtbs")
fi

NPROC=$(nproc)

make -j"$NPROC" ${TARGETS[@]}
if [[ $? -ne 0 ]]; then
	exit
fi

if [[ -n "$MODULES_PATH" ]]; then
	rm -rf "$MODULES_PATH"
	mkdir -p "$MODULES_PATH"
	make -j"$NPROC" INSTALL_MOD_PATH="$MODULES_PATH" modules_install
fi

if [[ -n "$HEADERS_PATH" ]]; then
	rm -rf "$HEADERS_PATH"
	mkdir -p "$HEADERS_PATH"
	make -j"$NPROC" INSTALL_HDR_PATH="$HEADERS_PATH" headers_install
fi
