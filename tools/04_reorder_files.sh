#!/usr/bin/env bash

# --------------------------------------------
# usage
# --------------------------------------------
USAGE=$(cat <<-EOF
Usage:
$(basename $0)
$(basename $0) --help

Due to deleted pages loops over all scanned files with file ending '*.tiff' 
inside the 'Working Directory' and renames each file that the resulting file 
name sequence, that starts at the 'Start Page Number' and has finally no gaps 
in the file naming.

Valid values for 'Working Directory', 'Start Page Number' and 'Document ID'must 
be set by environment variables!

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
if [ -z "${SCAN_WORKING_DIRECTORY}" -o -z "${SCAN_DOCUMENT_ID}" ]; then
	echo "${USAGE}"
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
# reorder files
# --------------------------------------------
echo 'reorder files...'
counter=${SCAN_PAGE_START_NUMBER}
for file in ${SCAN_DOCUMENT_ID}_*.tiff; do
	echo "${file}"
	new=$(printf "${SCAN_DOCUMENT_ID}_%03d.tiff" ${counter})
	if [ ! "${file}" = "${new}" ]; then
		mv -f ${file} ${new}
	fi
	let counter=${counter}+1
done
