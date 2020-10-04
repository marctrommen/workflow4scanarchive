#!/usr/bin/env python3
# -*- coding: utf-8 -*-
 
import argparse
import os
import fpdf
import json

# -----------------------------------------------------------------------------
# Version of current script as date string, formatted as 'YYYY-MM-DD'
# -----------------------------------------------------------------------------
SCRIPT_VERSION = "2020-07-21"
AUTHOR = "Marcus Trommen (mailto:marcus.trommen@gmx.net)"

EPILOG = '''
Author:  {}
Version: {}
'''.format(AUTHOR, SCRIPT_VERSION)


# -----------------------------------------------------------------------------
# file extensions

TXT_EXTENSION = ".txt"
PNG_EXTENSION = ".png"
PDF_EXTENSION = ".pdf"
JPG_EXTENSION = ".jpg"
JSON_EXTENSION = ".json"

# -----------------------------------------------------------------------------
def parse_command_line_arguments():

	'''Parse the command-line arguments for this program.'''

	description='''Merges all scanned PNG images and all OCR texts into one
PDF document
'''

	cli_parser = argparse.ArgumentParser(formatter_class=argparse.RawTextHelpFormatter
		, epilog=EPILOG
		, description=description)

	args={}
	args["SCAN_WORKING_DIRECTORY"] = os.environ["SCAN_WORKING_DIRECTORY"]
	args["SCAN_DOCUMENT_ID"] = os.environ["SCAN_DOCUMENT_ID"]
	args["SCAN_PDF_FONT"] = os.environ["SCAN_PDF_FONT"]
	
	return args


# -----------------------------------------------------------------------------
def get_files_from_directory(path_to_files, filter_file_extension):

	filenames = []

	for filename in os.listdir(path_to_files):
		if filename.endswith(filter_file_extension):
			filename=os.path.join(path_to_files, filename)
			filenames.append(filename)

	filenames.sort()
	return filenames


# -----------------------------------------------------------------------------
def add_metadata_to_pdf(pdf_document, json_document):

	# load document metadata from JSON file
	metadata = {}
	with open(json_document, "r") as fileObject:
		metadata = json.load(fileObject)
		if not metadata:
			raise RuntimeError("JSON file should not be empty!")

	
	# metadata
	pdf_document.set_author("Marcus Trommen")
	pdf_document.set_creator("Scan Workflow with PyFPDF library")
	pdf_document.set_keywords(" ".join(metadata["keywords"]))
	pdf_document.set_subject(metadata["title"])
	pdf_document.set_title(metadata["id"])
	pdf_document.set_display_mode("fullpage", "continuous")
	
	return


# -----------------------------------------------------------------------------
def add_scans_to_pdf(pdf_document, args):
	filename_list = get_files_from_directory(args["SCAN_WORKING_DIRECTORY"], PNG_EXTENSION)
	#filename_list = get_files_from_directory(args["SCAN_WORKING_DIRECTORY"], JPG_EXTENSION)

	pdf_document.set_margins(left=0.0, top=0.0, right=0.0)
	
	for filename in filename_list:
		# image page
		pdf_document.add_page()
		pdf_document.image(filename, x = 0, y = 0, w = 210, h = 296, type = 'png')
		#pdf_document.image(filename, x = 0, y = 0, w = 296, type = 'jpg')

	return


# -----------------------------------------------------------------------------
def add_ocr_texts_to_pdf(pdf_document, args):
	filename_list = get_files_from_directory(args["SCAN_WORKING_DIRECTORY"], TXT_EXTENSION)

	pdf_document.set_margins(left=7.0, top=7.0, right=7.0)
	pdf_document.add_font('Mono', '', args["SCAN_PDF_FONT"], uni=True)
	pdf_document.set_font(family="Mono", style="", size=8)
	
	encoding="utf-8"
	
	for filename in filename_list:
		# text page
		text = []
		with open(filename, 'r', encoding=encoding) as fileObject:
			for line in fileObject:
				# skip empty lines
				line = line.strip()
				if not line == "" :
					text.append(line)
		
		pdf_document.add_page()
		pdf_document.write(h=3, txt="\n".join(text))
		
	return


# -----------------------------------------------------------------------------
# main program
# -----------------------------------------------------------------------------
if __name__ == '__main__':
	# parse command line arguments
	args = parse_command_line_arguments()
	
	origin_path = args["SCAN_WORKING_DIRECTORY"]
		
	pdf_path = os.path.join(
		origin_path, args["SCAN_DOCUMENT_ID"] + PDF_EXTENSION)
	
	json_path = os.path.join(
		origin_path, args["SCAN_DOCUMENT_ID"] + JSON_EXTENSION)

	pdf_document = fpdf.FPDF(orientation="P", unit="mm", format="A4")
	#pdf_document = fpdf.FPDF(orientation="L", unit="mm", format="A4")

	add_metadata_to_pdf(pdf_document, json_path)
	
	add_scans_to_pdf(pdf_document, args)

	add_ocr_texts_to_pdf(pdf_document, args)
	
	# close document
	pdf_document.close()
	pdf_document.output(pdf_path, 'F')
