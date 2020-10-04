#!/usr/bin/env python3.8
# -*- coding: utf-8 -*-

# -----------------------------------------------------------------------------
# The MIT License (MIT)
#
# Copyright (c) 2019 Marcus Trommen (mailto:marcus.trommen@gmx.net)
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# -----------------------------------------------------------------------------

import argparse
import os

import image_optimizer

# -----------------------------------------------------------------------------
# Version of current script as date string, formatted as 'YYYY-MM-DD'
# -----------------------------------------------------------------------------
SCRIPT_VERSION = "2020-07-23"
AUTHOR = "Marcus Trommen (mailto:marcus.trommen@gmx.net)"

EPILOG = '''
Author:  {}
Version: {}
'''.format(AUTHOR, SCRIPT_VERSION)


# -----------------------------------------------------------------------------
WORKING_DIRECTORY = os.environ["SCAN_WORKING_DIRECTORY"]

TIFF_EXTENSION = ".tiff"
PNG_EXTENSION = ".png"


# -----------------------------------------------------------------------------
def parse_command_line_arguments():

	'''Parse the command-line arguments for this program.'''

	description='''Compacts all TIFF images in a directory to PNG images 
while removing speckles, bleedthrough, etc.
'''

	cli_parser = argparse.ArgumentParser(formatter_class=argparse.RawTextHelpFormatter
		, epilog=EPILOG
		, description=description)

	cli_parser.add_argument('-v'
		, dest='value_threshold'
		, metavar='PERCENT'
		, type=percent
		, default='25'
		, help='background value threshold (default %(default)s)')

	cli_parser.add_argument('-s'
		, dest='sat_threshold'
		, metavar='PERCENT'
		, type=percent
		, default='20'
		, help='background saturation threshold (default %(default)s)')

	cli_parser.add_argument('-n'
		, dest='num_colors'
		, type=int
		, default=8
		, help='number of output colors (default %(default)s)')

	cli_parser.add_argument('-p'
		, dest='sample_fraction'
		, metavar='PERCENT'
		, type=percent
		, default=5
		, help='of pixels to sample (default %(default)s)')

	cli_parser.add_argument('-w'
		, dest='white_bg'
		, action='store_true'
		, default=False
		, help='make background white (default %(default)s)')

	cli_parser.add_argument('-S'
		, dest='saturate'
		, action='store_false'
		, default=True
		, help='do not saturate colors (default %(default)s)')
	
	cli_parser.add_argument("document_id"
		, nargs="?"
		, help = "the document_id (e.g. YYYYMMDD_xx")


	args = cli_parser.parse_args()
	
	return args


# -----------------------------------------------------------------------------
def percent(string):
	'''Convert a string (i.e. 85) to a fraction (i.e. .85).'''
	return float(string)/100.0


# -----------------------------------------------------------------------------
def get_files_from_directory(path_to_files, filter_file_extension):

	filenames = []
	file_name_extension_length=len(filter_file_extension)

	for filename in os.listdir(path_to_files):
		if filename.endswith(filter_file_extension):
			filename = os.path.basename(filename)
			filenames.append(filename[:-file_name_extension_length])
			print(filename, " ")

	filenames.sort()
	return filenames


# -----------------------------------------------------------------------------
# main program
# -----------------------------------------------------------------------------
if __name__ == '__main__':
	# parse command line arguments
	cli_args = parse_command_line_arguments()

	origin_path = os.path.join(WORKING_DIRECTORY)
	
	filename_list = get_files_from_directory(origin_path, TIFF_EXTENSION)

	for filename in filename_list:

		input_filename = os.path.join(origin_path, filename + TIFF_EXTENSION)
		output_filename = os.path.join(origin_path, filename + PNG_EXTENSION)

		image_optimizer.optimize(
			input_filename
			, cli_args.sample_fraction
			, cli_args.value_threshold
			, cli_args.sat_threshold
			, cli_args.num_colors
			, cli_args.saturate
			, cli_args.white_bg
			, output_filename)
