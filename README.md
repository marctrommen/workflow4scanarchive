# Workflow for Scan Archive

The following description is **PART ONE** of two parts description for a whole
document archive system. **PART ONE** deals with the scanning of documents, 
collecting some meta information for further usage, 
enhancing the quality of the documents, reducing the file size of
them drastically, extract with the help of OCR tools (Tesseract) some plain 
text, putting the scanned images and extracted texts into one PDF with some
(previously collected) meta information and finally organizing all the files 
within a simple tree structure onto your file system.

[![MIT License][LICENSE-BADGE]](LICENSE)
![Linux][LINUX-BADGE]
![Python 3.x][PYTHON-BADGE]
![Bash 4][Bash-BADGE]


[LICENSE-BADGE]: https://img.shields.io/badge/license-MIT-blue.svg
[LINUX-BADGE]: https://img.shields.io/badge/Linux-blue.svg
[PYTHON-BADGE]: https://img.shields.io/badge/Python-3.x-blue.svg
[Bash-BADGE]: https://img.shields.io/badge/Bash-4-blue.svg



**PART TWO** will handle with the genaration of a static Webpage as a simple,
yet powerful document search and retrieval system to simply get and view your 
documents as PDF within your web browser.

The idea and some rudimental parts of the workflow is leaned on a 
[Blog Entry (on 'SPLITBRAIN.ORG', Paper Backup)](https://www.splitbrain.org/blog/2014-08/23-paper_backup_1_scanner_setup).


## Requirements

*   Python 3.8.0 or later
*   Python library NumPy 1.10 or later for image optimization
*   Python library SciPy 1.5.1 or later for image optimization
*   Python library Pillow 7.2.0 or later for image optimization
*   Python library FPDF 1.7.2 or later for PDF generation
*   Tessaract 3.04.01 or later as OCR solution
*   [ImageMagick 6.9.7-4 Q16 x86_64 20170114](http://www.imagemagick.org)
    or later for image optimization


## Installation

I assume you have already installed Python (version 3.8.0 or later) on your 
local system.

Extracting the ZIP archive into any directory of your choice will give you the
following file and directory layout:

```
scan installation directory
├── LICENSE.txt
├── README.md
├── requirements.txt
├── python_version.txt
├── 00_init.sh
├── 01_set_document_id.sh
├── 01_shortcut.sh
├── do_scan.sh
└── tools
    ├── 02_multiscan.sh
    ├── 02_singlescan.sh
    ├── 03_delete_blank_pages.sh
    ├── 04_reorder_files.sh
    ├── 05_cut_borders.sh
    ├── 06_apply_text_cleaning.sh
    ├── 07_ocr.sh
    ├── 08_optimize_scans.py
    ├── 09_create_pdf.py
    └── image_optimizer.py
```

Fulfilling all 3rd party library dependencies, just enter the following
commands at the command line.

**For the Python libraries do ...**

```
$> python3.8 -m pip install -r requirements.txt
```


**For the ImageMagick Apps do ...**

```
$> sudo apt install imagemagick
```

**For the Tesseract Apps do ...**

```
$> sudo apt install tesseract-ocr tesseract-ocr-deu tesseract-ocr-eng
```


## Configuration of the Environment

TODO

*   Setting up the directory name (`SCAN_ARCHIVE_BASE_DIRECTORY`) for the 
    archive and the font (`SCAN_PDF_FONT`) for the OCR texts, which get 
    integreated into the resulting PDF document.

    Edit the files `00_init.sh` and `00_shortcut.sh`

*   Setting up the parameters of your scanner

    Edit the files `tools/02_singlescan.sh` and `tools/02_multiscan.sh`
    
    For Details please refer to 
    [Scanner Installation and Configuration](scanner_installation_configuration.md)


## File and Directory Layout of Document File Archive

### General Idea

The general idea behind the *scan document archive* is, that any 
*atomic ressource* is a single file. This file can be a PDF document with one
or many pages or any other file or document type which can be directly shown
within a web browser, e.g. picture image files (e.g. PNG, TIFF, JPEG), simple
text files (e.g. TXT, MD, LOG) or office files (e.g. DOCX, ZIP, XLSX). 
Each *atomic ressource* is named with an *unique identifier*, the so called 
*Document_ID*. For further details on *Document_ID* please refer to 
[Naming Rules](naming_rules.md). Important is only that 
**only one document file is related to one Document_ID**! In case you have more
than one document for any use case (e.g. you have bought a new dishwasher and
you have three documents related to it: the bill, the manual and the 
installation instructions) then you need to create for each document file it's
own *Document_ID*!


### Document's Meta Information as JSON-File

For each new document the scan tools will create an empty JSON text file as a
form template for the document's meta information, which you need to complete
with a simple text editor (e.g. *vi* or *medit*).

The JSON file will look like this example:

```
{
    "id"       : "20181025_01",
    "title"    : "Manual for Dishwasher, bought on 2018-10-25",
    "file"     : "20181025_01.pdf",
    "keywords" : [ "manual", "dishwasher" ],
    "storage_location" : "document box"
}
```

The individual field have the following meaning:

*   `id` ... the *Document_ID* in the format of `YYYYMMDD_xx`(for further 
    details please refer to [Naming Rules](naming_rules.md))

*   `title` ... the *Title* of the document, which can be the headline of the 
    document's content or just a description of what the document is about

*   `file` ... the file name of the document which simply consists of two parts:
    the *Document_ID* and the file extension (e.g. ".pdf")

*   `keywords` ... list of keywords for characterizing the content of the 
    document. This supports the concept to group documents to certain keywords.
    Doing this they can be searched by keywords, e.g. all 'bills' can be grouped
    and later on searched.

*   `storage_location` ... this should help you to find the original document 
    again, in case you will need it in the future (e.g. contracts, certificates, 
    bills). In case the scaned document is just a temporary information you can 
    throw away the original and you can give a hint here, like "trash". A 
    further aspect could be that you got the "original" as an electronic 
    document via e-mail or you have just downloaded from somewhere. Then you 
    can give a proper hint to yourself as well, e.g. "email" or "download".


### File and Directory Layout

As there will be a couple of files existing for each *Document_ID*, they should
get grouped in separated directories, each simply named with the *Document_ID*.
So the *scan document archive* will be organized into a tree structure where
just below the `<SCAN_ARCHIVE_BASE_DIRECTORY>` there will be an endless list of
`<DOCUMENT_ID>` directories:

```
<SCAN_ARCHIVE_BASE_DIRECTORY>
├── <DOCUMENT_ID>
├── <DOCUMENT_ID>
...
```

Example:

```
scan archive base directory
├── 20190721_01
├── 20190721_02
...
```

Below each directory for any `<DOCUMENT_ID>` there will be a set of working 
files which hold meta information, the PDF document itself, the OCR files, 
the scanned pages as TIFF files, the optimized scans as PNG files. All file
names will start with the `<DOCUMENT_ID>`!

Example:

```
20190721_01
├── 20190721_01.json
├── 20190721_01.pdf
├── 20190721_01_001.png
├── 20190721_01_001.tiff
├── 20190721_01_002.png
└── 20190721_01_002.tiff
```


## General Usage of the Command Line Tools

TODO


## Use Cases

TODO


### Existing Document File

In case you have already an electronic document of any file format (e.g. PDF,
Office-DOC, PNG, JPEG) you would like to organize it within the 
*scan document archive*, just follow the steps below.

Create below the *scan archive base directory* a directory with a new but 
fitting *Document_ID* and copy your existing document into it.

```
$> mkdir <SCAN_ARCHIVE_BASE_DIRECTORY>/<DOCUMENT_ID>
$> cp <YOUR_DOCUMENT> <SCAN_ARCHIVE_BASE_DIRECTORY>/<DOCUMENT_ID>/<DOCUMENT_ID>.<EXTENSION>
$> <SCAN_INSTALLATION_DIRECTORY>/source 00_shortcut.sh <DOCUMENT_ID>
```

Example:

```
$> mkdir <SCAN_ARCHIVE_BASE_DIRECTORY>/20200521_02
$> cp dishwasher_manual.pdf <SCAN_ARCHIVE_BASE_DIRECTORY>/20200521_02/20200521_02.pdf
$> <SCAN_INSTALLATION_DIRECTORY>/source 00_shortcut.sh 20200521_02
```

With the called shell script  `00_shortcut.sh` a JSON file as template for
the document's meta data with prefilled information was created and just needs
to get completed with the help of an editor, e.g. `vi`:

```
$> vi ${SCAN_ARCHIVE_BASE_DIRECTORY}/${SCAN_DOCUMENT_ID}/${SCAN_DOCUMENT_ID}.json
```

Then you will be done.


### Already Scanned Document Pages as a Set of TIFF or PNG Files

TODO


### Scanning any new Document with Double Sided Autofeed Scanner

TODO

```
$> source 00_init.sh
$> source 01_set_document_id.sh <DOCUMENT_ID>
$> vi ${SCAN_ARCHIVE_BASE_DIRECTORY}/${SCAN_DOCUMENT_ID}/${SCAN_DOCUMENT_ID}.json
$> bash do_scan.sh
```

Example:

```
$> source 00_init.sh
$> source 01_set_document_id.sh 20200717_01
$> vi ${SCAN_ARCHIVE_BASE_DIRECTORY}/${SCAN_DOCUMENT_ID}/${SCAN_DOCUMENT_ID}.json
$> bash do_scan.sh
```


### Scanning any new Document with a Flatbed Scanner

TODO

```
$> source 00_init.sh
$> source 01_set_document_id.sh <DOCUMENT_ID>
$> vi ${SCAN_ARCHIVE_BASE_DIRECTORY}/${SCAN_DOCUMENT_ID}/${SCAN_DOCUMENT_ID}.json
$> bash tools/02_singelscan.sh <page_number>
$> bash do_scan.sh cut_borders
```

Example for a 3 pages document:

```
$> source 00_init.sh
$> source 01_set_document_id.sh 20200717_01
$> vi ${SCAN_ARCHIVE_BASE_DIRECTORY}/${SCAN_DOCUMENT_ID}/${SCAN_DOCUMENT_ID}.json
$> bash tools/02_singelscan.sh 1
$> bash tools/02_singelscan.sh 2
$> bash tools/02_singelscan.sh 3
$> bash do_scan.sh cut_borders
```


## Recommendations for Programm Enhancements

In case of any recommendations for programm enhancements or further
requirements, do not hesitate to contact me via e-mail 
(mailto:marcus.trommen@gmx.net)
