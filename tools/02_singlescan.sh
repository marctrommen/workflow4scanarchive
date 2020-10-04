#!/usr/bin/env bash

# --------------------------------------------
# usage
# --------------------------------------------
USAGE=$(cat <<-EOF
Usage: 
$(basename $0) <page_number>
$(basename $0) --help

Scan one page (single sided) with flatbed scanner (e.g. HP Officejet Pro 8600)
and save it as TIFF file into SCAN_WORKING_DIRECTORY named 
SCAN_DOCUMENT_ID with <page_number> postfix; e.g. "YYYYMMDD_xx_001" (if
<page_number> got set to '1').

Valid values for 'Scan Device', 'Working Directory' and 'Document ID' must be 
set by environment variables!

SCAN_DEVICE
    Valid device id of scanner for 'scanimage' app

SCAN_WORKING_DIRECTORY
    Valid pathname where to save all scanned documents

SCAN_DOCUMENT_ID
    Please provide unique document_id (YYYYMMDD_xx) name as first parameter
    Example: 20200317_01

<page_number>
    page number for target file of scan
    
    example:
    '5' for <page_number> will result in "YYYYMMDD_xx_005.tiff" as file name

EOF
)


# --------------------------------------------
# print usage
# --------------------------------------------
if [ "$1" = "--help" ]; then
	echo "${USAGE}"
	exit 1
else
	if [ ! "$1" = "" ]; then
		PAGE_NUMBER="$1"
	else
		echo "${USAGE}"
		exit 1
	fi
fi


# --------------------------------------------
# retrieve and check necessary environment variables
# --------------------------------------------
export SCAN_DEVICE=${SCAN_DEVICE:-""}
export SCAN_WORKING_DIRECTORY=${SCAN_WORKING_DIRECTORY:-""}
export SCAN_DOCUMENT_ID=${SCAN_DOCUMENT_ID:-""}


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
# check for target file
# --------------------------------------------
TARGET_FILE=$(printf "${SCAN_DOCUMENT_ID}_%03d.tiff" ${PAGE_NUMBER})
if [ -f "${SCAN_WORKING_DIRECTORY}/${TARGET_FILE}" ]; then
	echo "ERROR: target file (${TARGET_FILE}) for scan does already exist!"
	exit 1
fi

# --------------------------------------------
# scann single page from flatbed
# --------------------------------------------
echo "scanning on ${SCAN_DEVICE} ..."
scanimage --device-name=${SCAN_DEVICE} \
          --format=tiff \
          --source 'Flatbed' \
          --mode 'Color' \
          --resolution 300 \
          --brightness 1000 \
          --contrast 1000 \
          --compression None \
         > ${SCAN_WORKING_DIRECTORY}/${TARGET_FILE}

if [ "$?" -gt "0" ]; then
	echo "ERROR: wrong scanner interface set!"
	echo "       please run 00_scan_device.sh"
	exit 1
fi

echo "Output ${TARGET_FILE} in ${SCAN_WORKING_DIRECTORY}"

exit 0
