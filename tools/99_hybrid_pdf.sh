#!/bin/bash
 
# --------------------------------------------
# print usage
# --------------------------------------------
if [ -z "$1" ]; then
	echo "Usage: $0 <jobid>"
	echo
	echo "Please provide unique document_id (YYYYMMDD_xx) name as first parameter"
	exit 1
fi

# --------------------------------------------
# settings
# --------------------------------------------
BASE=$(dirname $(realpath $0))
DOC_ID=$1
OUTPUT="${BASE}/${DOC_ID}"
RESOLUTION=150 # dpi

# --------------------------------------------
# check for directory
# --------------------------------------------
if [ ! -d "${OUTPUT}" ]; then
	echo "working directory (${OUTPUT}) does not exist"
	exit 1
fi
 
cd "$OUTPUT"

# --------------------------------------------
# create hybrid pdf from png and ocr-text
# --------------------------------------------
echo 'doing hybrid pdf...'
for png_file in ${DOC_ID}_*.png; do
	file=$(basename ${png_file} | awk -F\. '{print $1}')
	echo "${file}"
	
	if [ ! -f "${file}.txt" ]; then
		echo "ocr-text file does not exist"
		exit 1
	fi
	
	hocr2pdf --input "${png_file}" -s -r ${RESOLUTION} --output "${file}.pdf" < "${file}.txt"
done

# --------------------------------------------
# merge alle hybrid pdf pages to one pdf document
# --------------------------------------------
echo 'creating PDF...'
pdftk ${DOC_ID}_*.pdf cat output "${DOC_ID}.pdf"

echo "created ${OUTPUT}/${DOC_ID}.pdf"