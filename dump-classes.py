#!/usr/bin/python
from subprocess import call
import glob
import os
import sys
import fileinput
import re

destination_path = 'Multiplex/Modules/IDEHeaders/IDEHeaders/'

def dump_all_frameworks():
	# 3 different directories contain all of the frameworks a plugin may interface with.
	# They're located at {APP_DIR}/Contents/
	shared_frameworks = ['DVTFoundation', 'DVTKit']
	frameworks = ['IDEFoundation', 'IDEKit']
	other_frameworks = ['']

	for framework in shared_frameworks:
		dump_framework(frameworkPath('SharedFrameworks', framework), frameworkDumpDestination(framework))

	for framework in frameworks:
		dump_framework(frameworkPath('Frameworks', framework), frameworkDumpDestination(framework))
	
	cleanup_dumped_files()

def frameworkPath(frameworkDir, frameworkName):
	framework_root_directory = '/Applications/Xcode-beta.app/Contents/'
	return framework_root_directory + frameworkDir + '/' + frameworkName + '.framework/' + frameworkName

def frameworkDumpDestination(frameworkName):
	return destination_path + frameworkName

def dump_framework(path, destinationDir):
	call(['class-dump', path, '-H', '-s', '-o', destinationDir])

def cleanup_dumped_files():
	relative_paths = glob.glob(destination_path + '/*/*.h')
	for relativePath in relative_paths:
		absolute_path = os.path.abspath(relativePath)
		cleanFile(absolute_path)

def cleanFile(filePath):
	tempName = filePath + '.tmp'
	inputFile = open(filePath)

	outputFile = open(tempName, 'w')
	fileContent = unicode(inputFile.read(), "utf-8")

	# Remove Foundation imports
	outText = re.sub('#import "NS(.*?).h"\n', '', fileContent)
	
	# Remove .cxx_destructs
	outText = re.sub('- \(void\).cxx_destruct;\n', '', outText)

	# Fix delegate imports
	outText = re.sub('.h"', '-Protocol.h"', outText)

	# Add import for structs
	outText = re.sub('//\n\n', '//\n\n#import "CDStructures.h"\n', outText)

	# Change the unknown block type to a generic block that doesn't need an import
	outText = re.sub('CDUnknownBlockType', 'dispatch_block_t', outText)

	# Remove protocols from ivars as they're not supported
	outText = re.sub('<(.*?)> (\*|)', ' ' + r"\2", outText)

	outputFile.write((outText.encode("utf-8")))

	outputFile.close()
	inputFile.close()

	os.rename(tempName, filePath)

dump_all_frameworks()
