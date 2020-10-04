#!/usr/bin/env bash

# --------------------------------------------
# usage
# --------------------------------------------
USAGE=$(cat <<-EOF
Usage: 
$(basename $0)
$(basename $0) --help

Scan all pages (double sided) in tray of Fujitsu ScanSnap S1300i.

Valid values for 'Scan Device', 'Working Directory', 'Document ID' and
'Start Page Number' must be set by environment variables!

SCAN_DEVICE
    Valid device id of scanner for 'scanimage' app

SCAN_WORKING_DIRECTORY
    Valid pathname where to save all scanned documents

SCAN_DOCUMENT_ID
    Please provide unique document_id (YYYYMMDD_xx) name as first parameter
    Example: 20200317_01

SCAN_PAGE_START_NUMBER
    Optional parameter for setting the start page numbering for the scanned
    documents in multiscan mode. If not set, value defaults to '1'

EOF
)


# --------------------------------------------
# print usage
# --------------------------------------------
if [ "$1" = "--help" ]; then
	echo "${USAGE}"
	exit 1
fi


# --------------------------------------------
# retrieve and check necessary environment variables
# --------------------------------------------
export SCAN_DEVICE=${SCAN_DEVICE:-""}
export SCAN_WORKING_DIRECTORY=${SCAN_WORKING_DIRECTORY:-""}
export SCAN_DOCUMENT_ID=${SCAN_DOCUMENT_ID:-""}


# --------------------------------------------
# retrieve and check optional environment variables
# --------------------------------------------
export SCAN_PAGE_START_NUMBER=${SCAN_PAGE_START_NUMBER:-""}

if [ -z "${SCAN_PAGE_START_NUMBER}" ]; then
	export SCAN_PAGE_START_NUMBER=1
elif [ "${SCAN_PAGE_START_NUMBER}" -lt "1" ]; then
	export SCAN_PAGE_START_NUMBER=1
fi


# --------------------------------------------
# print usage
# --------------------------------------------
if [ -z "${SCAN_DEVICE}" -o -z "${SCAN_WORKING_DIRECTORY}" -o -z "${SCAN_DOCUMENT_ID}" ]; then
	echo "${USAGE}"
	echo "SCAN_DEVICE: ${SCAN_DEVICE}"
	echo "SCAN_WORKING_DIRECTORY: ${SCAN_WORKING_DIRECTORY}"
	echo "SCAN_DOCUMENT_ID: ${SCAN_DOCUMENT_ID}"
	echo "SCAN_PAGE_START_NUMBER: ${SCAN_PAGE_START_NUMBER}"
	exit 1
fi


# --------------------------------------------
# check for working directory
# --------------------------------------------
if [ ! -d "${SCAN_WORKING_DIRECTORY}" ]; then
	echo "ERROR: working directory (${SCAN_WORKING_DIRECTORY}) does not exist!"
	exit 1
fi

cd "${SCAN_WORKING_DIRECTORY}"


# --------------------------------------------
# scann all pages in tray
# --------------------------------------------
echo "scanning on ${SCAN_DEVICE} ..."
scanimage --device-name=${SCAN_DEVICE} \
          --batch="${SCAN_WORKING_DIRECTORY}/${SCAN_DOCUMENT_ID}_%03d.tiff" \
          --batch-start=${SCAN_PAGE_START_NUMBER} \
          --format=tiff \
          --source 'ADF Duplex' \
          --mode 'Color' \
          --resolution 300 \
          --brightness 0 \
          --contrast 0 \
          -t 0 \
          --page-width 205 \
          --page-height 296

if [ "$?" -gt "0" ]; then
	echo "ERROR: wrong scanner interface set!"
	echo "       please run 00_scan_device.sh"
	exit 1
fi

echo "Output in ${SCAN_WORKING_DIRECTORY}"

exit 0
