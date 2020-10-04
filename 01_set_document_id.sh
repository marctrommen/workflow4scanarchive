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

It will get checked, document_id is not already used!
Sets environment variables for 
'Document ID' (SCAN_DOCUMENT_ID), 
'Working Directory' (SCAN_WORKING_DIRECTORY) and
'Start Page Number' (SCAN_PAGE_START_NUMBER).
Then a new directory (SCAN_WORKING_DIRECTORY) gets created out of the 
'archive base directory'and the 'Document ID' as container for all files to 
hold. Further a JSON file gets created as container for document's metadata.

Valid values for 'Scan Device' and 'Scan Archive Directory' must be set by 
environment variables!

    SCAN_DEVICE, SCAN_ARCHIVE_BASE_DIRECTORY

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
# check for Scan Archive Directory
# --------------------------------------------
if [ ! -d "${SCAN_ARCHIVE_BASE_DIRECTORY}" ]; then
	cat <<-EOF
	
	ERROR:
	Archive Base Directory (${SCAN_ARCHIVE_BASE_DIRECTORY}) is not available 
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
# settings
# --------------------------------------------
SCAN_DOCUMENT_ID=$1
SCAN_WORKING_DIRECTORY="${SCAN_ARCHIVE_BASE_DIRECTORY}/${SCAN_DOCUMENT_ID}"


# --------------------------------------------
# check for working directory and document_id
# --------------------------------------------
if [ -d "${SCAN_WORKING_DIRECTORY}" ]; then
	cat <<-EOF
	
	WARNING:
	Working directory (${SCAN_WORKING_DIRECTORY}) 
	for 'document_id' ${SCAN_DOCUMENT_ID} does already exist!!
	
	Please, check this and change the <document_id> if necessary!
	Cannot continue process!
	EOF
	
	export SCAN_DOCUMENT_ID=""
	export SCAN_WORKING_DIRECTORY=""
	export SCAN_PAGE_START_NUMBER=""
	return 1
fi


# --------------------------------------------
# create working directory
# --------------------------------------------
echo "create working directory (${SCAN_WORKING_DIRECTORY})..."
mkdir -p "${SCAN_WORKING_DIRECTORY}"


# --------------------------------------------
# check for working directory
# --------------------------------------------
if [ ! -d "${SCAN_WORKING_DIRECTORY}" ]; then
	cat <<-EOF
	
	ERROR:
	Working Directory (${SCAN_WORKING_DIRECTORY}) could not get created
	for holding all	scanned documents!
	
	Cannot continue process!
	EOF
	
	export SCAN_DOCUMENT_ID=""
	export SCAN_WORKING_DIRECTORY=""
	export SCAN_PAGE_START_NUMBER=""
	exit 1
fi

export SCAN_WORKING_DIRECTORY
export SCAN_DOCUMENT_ID
export SCAN_PAGE_START_NUMBER


# --------------------------------------------
# do JSON
# --------------------------------------------
echo 'create JSON file...'
JSON_FILE="${SCAN_WORKING_DIRECTORY}/${SCAN_DOCUMENT_ID}.json"
echo "${JSON_FILE}"
JSON_CONTENT=$(cat <<-EOF
{
    "id"       : "${SCAN_DOCUMENT_ID}",
    "title"    : "",
    "file"     : "${SCAN_DOCUMENT_ID}.pdf",
    "keywords" : [ "", "" ],
    "storage_location" : "Papier-Ablage"
}
EOF
)
echo "${JSON_CONTENT}" > ${JSON_FILE}

return 0
