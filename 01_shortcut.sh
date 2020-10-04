#!/usr/bin/env bash

# --------------------------------------------
# check call context of script
# --------------------------------------------
if [ $_ != $0 ]; then
	# Script is being sourced
	SCRIPT_IS_SOURCED="1"
else
	# Script runs in a subshell
	SCRIPT_IS_SOURCED=""
fi

# --------------------------------------------
# usage
# --------------------------------------------
USAGE=$(cat <<-EOF
Usage:
$(basename $0) <document_id> <start_page_number>
$(basename $0) --help

Use this script, if you have already (scanned or other electronic) documents 
you would like to add to the document archive process, but you do not want to 
start any scan activities.

It will set all necessary environment variables:

    SCAN_DOCUMENT_ID, SCAN_WORKING_DIRECTORY, SCAN_PAGE_START_NUMBER, 
    SCAN_WORKING_DIRECTORY, SCAN_PDF_FONT, SCAN_DEVICE

Further a JSON file gets created as container for document's metadata and preset
with the known values, as long as it does not already exists.

The directory named with the <document_id> should already exist, otherwise you
will get an error.


Input parameter:

<document_id>
    Please provide unique document_id (YYYYMMDD_xx) name as first parameter
    Example: 20200317_01

<start_page_number>
    Optional parameter for setting the start page numbering for the scanned
    documents in multiscan mode. If not set, value defaults to '1'

IMPORTANT:
    This file must be used with "source" from bash command line.
    You cannot run it directly!

EOF
)

# --------------------------------------------
# print usage
# --------------------------------------------
if [ -z "${SCRIPT_IS_SOURCED}" ]; then
	# Script runs in a subshell
	if [ "$1" = "--help" ]; then
		echo "${USAGE}"
		exit 1
	fi
	
	cat <<-EOF
	ERROR!
	This file must be used with "source" from bash command line.
	You cannot run it directly!
	EOF
	
	exit 1
fi

# Script is being sourced
if [ -z "$1" ]; then
	echo "${USAGE}"
	return 1
fi

if [ "$1" = "--help" ]; then
	echo "${USAGE}"
	return 1
fi


# --------------------------------------------
# check for optional Start Page Number
# --------------------------------------------
if [ -z "$2" ]; then
	# set default value
	SCAN_PAGE_START_NUMBER=1
else
	SCAN_PAGE_START_NUMBER=$2
fi


# --------------------------------------------
# settings
# --------------------------------------------
export SCAN_PAGE_START_NUMBER
export SCAN_PDF_FONT="/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf"
export SCAN_ARCHIVE_BASE_DIRECTORY="/media/marco/INTENSO/docarchive"
export SCAN_DOCUMENT_ID=$1
export SCAN_WORKING_DIRECTORY="${SCAN_ARCHIVE_BASE_DIRECTORY}/${SCAN_DOCUMENT_ID}"


# --------------------------------------------
# check for Scan Working Directory
# --------------------------------------------
if [ ! -d "${SCAN_WORKING_DIRECTORY}" ]; then
	cat <<-EOF
	
	ERROR:
	Scan Working Directory (${SCAN_WORKING_DIRECTORY}) is not available 
	for holding all	scanned documents!
	
	Cannot continue process!
	EOF
	
	export SCAN_DOCUMENT_ID=""
	export SCAN_ARCHIVE_BASE_DIRECTORY=""
	export SCAN_WORKING_DIRECTORY=""
	export SCAN_PAGE_START_NUMBER=""
	return 1
fi


# --------------------------------------------
# check for JSON file
# --------------------------------------------
JSON_FILE="${SCAN_WORKING_DIRECTORY}/${SCAN_DOCUMENT_ID}.json"
if [ -s "${JSON_FILE}" ]; then
	echo 'JSON file does already exist - done.'
	return 0
fi


# --------------------------------------------
# do JSON
# --------------------------------------------
echo 'create JSON file...'

echo "${JSON_FILE}"
JSON_CONTENT=$(cat <<-EOF
{
    "id"       : "${SCAN_DOCUMENT_ID}",
    "title"    : "",
    "file"     : "${SCAN_DOCUMENT_ID}.pdf",
    "keywords" : [ "", "" ],
    "storage_location" : "Archiv"
}
EOF
)
echo "${JSON_CONTENT}" > ${JSON_FILE}

return 0
