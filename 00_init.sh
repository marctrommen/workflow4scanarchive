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
source ./$(basename $0)

Initialize the scan process with Fujitsu ScanSnap S1300i with 'scanimage'
application. For this the actual 'Scan Device' will get evaluated and the 
'Scan Archive Base Directory' for the scan archive will get set.

Valid values for 'Scan Device', 'Scan Archive Base Directory' and 
'Scan PDF Font' must be set by environment variables:
    SCAN_DEVICE, SCAN_ARCHIVE_BASE_DIRECTORY, SCAN_PDF_FONT

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
		return 1
	fi
	
	echo "ERROR!"
	echo "This file must be used with 'source' from bash command line."
    echo "You cannot run it directly!"
	return 1
fi

# Script is being sourced
if [ "$1" = "--help" ]; then
	echo "${USAGE}"
	return 1
fi


# --------------------------------------------
# retrieve the actual scanner device name
# --------------------------------------------
SCANNER_DETECTION_ERROR=$(cat <<-EOF
ERROR:
No scanners were identified. If you were expecting something different,
check that the scanner is plugged in, turned on and detected by the
sane-find-scanner tool (if appropriate). Please read the documentation
which came with this software (README, FAQ, manpages).
EOF
)

SCAN_DEVICE=$(scanimage -L | awk -F\` '{print $2}' | awk -F\' '{print $1}')
if [ -z "${SCAN_DEVICE}" ]; then
	echo "${SCANNER_DETECTION_ERROR}"
	export SCAN_DEVICE=""
	export SCAN_PDF_FONT=""
	return 1
fi

export SCAN_DEVICE
echo "SCAN_DEVICE: ${SCAN_DEVICE}"


# --------------------------------------------
# SET Archive Base Directory
# --------------------------------------------
# alternative 1: directory of this script
#SCAN_ARCHIVE_BASE_DIRECTORY="$(dirname $(realpath $0))"

# alternative 2: external USB HDD
#SCAN_ARCHIVE_BASE_DIRECTORY="/media/marco/marco/DocArchive"

# alternative 3: 16 GB USB Stick intenso
SCAN_ARCHIVE_BASE_DIRECTORY="/media/marco/INTENSO/docarchive"

# --------------------------------------------
# check for directory
# --------------------------------------------
if [ ! -d "${SCAN_ARCHIVE_BASE_DIRECTORY}" ]; then
	echo "ERROR:"
	echo "SCAN_ARCHIVE_BASE_DIRECTORY (${SCAN_ARCHIVE_BASE_DIRECTORY}) does not exist!"
	export SCAN_ARCHIVE_BASE_DIRECTORY=""
	export SCAN_DEVICE=""
	export SCAN_PDF_FONT=""
	return 1
fi

export SCAN_ARCHIVE_BASE_DIRECTORY
echo "SCAN_ARCHIVE_BASE_DIRECTORY: ${SCAN_ARCHIVE_BASE_DIRECTORY}"


# --------------------------------------------
# SET Scan PDF Font
# --------------------------------------------
# to find installed fonts unter Debian Linux:
# $> fc-list
# you need to define full qualified path to font file!
SCAN_PDF_FONT="/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf"
if [ ! -f "${SCAN_PDF_FONT}" ]; then
	echo "ERROR:"
	echo "SCAN_PDF_FONT (${SCAN_PDF_FONT}) does not exist!"
	export SCAN_ARCHIVE_BASE_DIRECTORY=""
	export SCAN_DEVICE=""
	export SCAN_PDF_FONT=""
	return 1
fi

export SCAN_PDF_FONT
echo "SCAN_PDF_FONT: ${SCAN_PDF_FONT}"

return 0