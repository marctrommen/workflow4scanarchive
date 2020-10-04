#!/usr/bin/env bash

# --------------------------------------------
# usage
# --------------------------------------------
USAGE=$(cat <<-EOF
Usage:
$(basename $0)
$(basename $0) --help

Loops over all scanned files with file ending '*.tiff' in the 
'Working Directory' and delete pages (files) with no content.

Valid values for 'Working Directory' and 'Document ID'must be set by 
environment variables!

SCAN_WORKING_DIRECTORY
    Valid pathname where to save all scanned documents

SCAN_DOCUMENT_ID
    Please provide unique document_id (YYYYMMDD_xx) name as first parameter
    Example: 20200317_01
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
# print usage
# --------------------------------------------
if [ -z "${SCAN_WORKING_DIRECTORY}" -o -z "${SCAN_DOCUMENT_ID}" ]; then
	echo "${USAGE}"
	echo "SCAN_WORKING_DIRECTORY: ${SCAN_WORKING_DIRECTORY}"
	echo "SCAN_DOCUMENT_ID: ${SCAN_DOCUMENT_ID}"
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
# delete blank pages
# http://philipp.knechtges.com/?p=190
# --------------------------------------------
echo 'delete blank pages ...'
for file in ${SCAN_DOCUMENT_ID}_*.tiff; do
	echo "${file}"
	histogram=`convert "${file}" -threshold 50% -format %c histogram:info:-`
	white=`echo "${histogram}" | grep "#FFFFFF" | sed -n 's/^ *\(.*\):.*$/\1/p'`
	black=`echo "${histogram}" | grep "#000000" | sed -n 's/^ *\(.*\):.*$/\1/p'`
	blank=`echo "scale=4; ${black}/${white} < 0.005" | bc`

	if [ ${blank} -eq "1" ]; then
		echo "seems to be blank - removing it..."
		rm -f "${file}"
	fi
done
