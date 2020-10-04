#!/usr/bin/env bash

# --------------------------------------------
# print usage
# --------------------------------------------
USAGE=$(cat << EOF

Usage:
$(basename $0) <target>
$(basename $0) --help

scan all pages (double sided) in tray of Fujitsu ScanSnap S1300i, optimize 
quality and file size of scans, do character recognition (OCR) and create 
one PDF file.

Valid values for 'Scan Device', 'Working Directory' and 'Document ID' must be 
set by environment variables!

SCAN_DEVICE
    valid device id of scanner for 'scanimage' app

SCAN_WORKING_DIRECTORY
	valid 

SCAN_DOCUMENT_ID
    Please provide unique document_id (YYYYMMDD_xx) name as first parameter
    Example: 20200317_01

<target>
    set the target in a makefile like context. Possible values in given order
    are:

    multiscan 
            scan all pages (double sided) in tray of Fujitsu ScanSnap S1300i
    delete_blank_pages
            delete pages with no content
    reorder_files
            due to deleted pages rename the files in right order
    cut_borders
            cut off non used borders
    apply_text_cleaning
            prepare all pages for OCR with ImageMagick 
    ocr
            do character recognition (OCR) on all scans an extract to text files
    optimize_scans
            optimize contrast, reduce file size and convert scans to PNG format
    create_pdf
            merge all scan images and extracted text to one PDF file

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
# settings
# --------------------------------------------
BASE_DIR=$(dirname $(realpath $0))
BASE_DIR="${BASE_DIR}/tools"
BASH_INTERPRETER="bash"
PYTHON_INTERPRETER="python3.8"

if [ "$1" = "" ]; then
	TARGET="multiscan"
else
	TARGET="$1"
fi


# --------------------------------------------
# makefile like workflow
# --------------------------------------------
case "${TARGET}" in
	multiscan)
		${BASH_INTERPRETER} ${BASE_DIR}/02_multiscan.sh
		if [ "$?" -gt "0" ]; then
			echo "ERROR!"
			exit 1
		fi
		;&
	
	delete_blank_pages)
		${BASH_INTERPRETER} ${BASE_DIR}/03_delete_blank_pages.sh
		if [ "$?" -gt "0" ]; then
			echo "ERROR!"
			exit 1
		fi
		;&
	
	reorder_files)
		${BASH_INTERPRETER} ${BASE_DIR}/04_reorder_files.sh
		if [ "$?" -gt "0" ]; then
			echo "ERROR!"
			exit 1
		fi
		;&
	
	cut_borders)
		${BASH_INTERPRETER} ${BASE_DIR}/05_cut_borders.sh
		if [ "$?" -gt "0" ]; then
			echo "ERROR!"
			exit 1
		fi
		;&
	
	apply_text_cleaning)
		${BASH_INTERPRETER} ${BASE_DIR}/06_apply_text_cleaning.sh
		if [ "$?" -gt "0" ]; then
			echo "ERROR!"
			exit 1
		fi
		;&
	
	ocr)
		${BASH_INTERPRETER} ${BASE_DIR}/07_ocr.sh
		if [ "$?" -gt "0" ]; then
			echo "ERROR!"
			exit 1
		fi
		;&
	
	optimize_scans)
		${PYTHON_INTERPRETER} ${BASE_DIR}/08_optimize_scans.py
		if [ "$?" -gt "0" ]; then
			echo "ERROR!"
			exit 1
		fi
		;&
	
	create_pdf)
		${PYTHON_INTERPRETER} ${BASE_DIR}/09_create_pdf.py
		if [ "$?" -gt "0" ]; then
			echo "ERROR!"
			exit 1
		fi
		;;
	
	*)
		echo "${USAGE}"
		exit 1
esac

echo "DONE !"
exit 0
