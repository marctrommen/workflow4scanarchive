#!/usr/bin/env bash

# --------------------------------------------
# usage
# --------------------------------------------
USAGE=$(cat <<-EOF
Usage:
$(basename $0)
$(basename $0) --help

Loops over all scanned files with file ending '*.tiff' and all OCR files with
file ending '*.txt' in the 'Working Directory' and merge them to one PDF file.
PDFTK is getting used for creating hybrid PDF file.

Valid values for 'Working Directory' and 'Document ID' must be set by 
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
# create hybrid pdf from png and ocr-text
# --------------------------------------------
echo 'doing hybrid pdf...'
for png_file in ${SCAN_DOCUMENT_ID}_*.png; do
	file=$(basename ${png_file} | awk -F\. '{print $1}')
	echo "${file}"
	
	convert "${png_file}" "${file}.pdf"
done

# --------------------------------------------
# merge alle hybrid pdf pages to one pdf document
# --------------------------------------------
echo 'creating PDF...'
pdftk ${SCAN_DOCUMENT_ID}_*.pdf cat output "${SCAN_DOCUMENT_ID}.pdf"

echo "created ${SCAN_WORKING_DIRECTORY}/${SCAN_DOCUMENT_ID}.pdf"

exit 0
