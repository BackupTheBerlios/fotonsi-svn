#!/usr/bin/env python
import sys

class jack:
	_htmlHead = "<html>\n<body>\n<table>\n"
	_htmlBottom = "</table>\n</body>\n</html>"

	def __init__ (self, fic, prefix):
		self.f = open (fic)
		self.filePrefix = prefix

	def readline (self):
		"""
			Read a line and remove comments
		"""

		lin = self.f.readline()

		# If line is empty, return -1 
		if (len(lin) == 0):
			return -1

		# Removes \n and \r
		lin = lin.replace ("\n", "").replace ("\r", "")

		# When a comment is found...
		if (lin.find("#") >= 0):
			
			# If it's at the start of line, continue reading until a normal line is found
			if (lin[0] == "#"):
				while ((len(lin)>0) and (lin[0] == "#")):
					lin = self.f.readline()
			# Otherwise, remove the comment from the line
			else:
				lin = lin.split("#")[0].strip()
		return lin

	def parse (self):
		lin = "" # Current line
		lin_prev = "" # Previous line
		cont = 0 # Counter for tests files
		f = None # File to save individual tests
		contenido = False # Flag to control if content si saved to file

		lin = self.readline()
		
		# First line of file may have URL var
		if (lin.find("URL") >= 0):
			# Extract URL value and continue reading
			URL = lin.split("=")[1]
			existe_URL = True
			lin = self.readline()
	
		# Now we have the title
		maintitle = lin.replace ("\n", "")

		# Continue to first test...
		lin = self.readline()
		lin = self.readline()

		# Titles of individual tests
		titles = list()
	
		# Walks along the file
		while lin <> -1:
			# When ---- is found, starts a new test
			# Previous line is the title of test
			if (len(lin)>0) and (lin[0] == "-"):
				contenido = True
				title = lin_prev

				# Read another line in order to skip dashes line
				lin = self.readline()
				cont = cont + 1
			
				# Formats file name (prefix + counter)
				nfic = "%s%d.html" % (self.filePrefix, cont)

				# Saves title of current test
				titles.append ((lin_prev, nfic))
				
				# Open html file to save the test
				f = open (nfic, "w")
				f.write (self._htmlHead)
				f.write ('<tr><td colspan="3">%s</td></tr>\n' % (title))

				# Jump to read another line
				continue

			# When an empty line is read, finish current block of test
			elif (len(lin) == 0):
				contenido = False

				# Write the bottom of HTML and close the file
				f.write (self._htmlBottom)
				f.close()

			# If we are inside a test block, save the content into HTML
			elif (contenido == True):
				# Replaces $URL var if found
				if ((lin.find("$URL") > 0) and (existe_URL==True)):
					lin = lin.replace ("$URL", URL)

				cols = lin.split (" ")
				
				# Append a HTML column to prevent two column commands (selenium requires three columns on each test line)
				if (len (cols) == 2):
					cols.append("")
				
				f.write ("<tr><td>%s</td><td>%s</td><td>%s</td></tr>\n" % (cols[0], cols[1], cols[2]))
			
			# Store current line as previous and read a new one
			lin_prev = lin
			lin = self.readline()
	
		# Parsing is finished... write HTML footer and close the file
		f.write (self._htmlBottom)
		f.close()

		# Writes the main file
		f = open ("%s.html" % (self.filePrefix), "w")

		s = self._htmlHead
		
		# First line of file will be the title
		s = s + '<tr><td colspan="3">%s</td></tr>\n' % (maintitle)

		# Creates the main column from the titles (each[0]) and associated file (each[1])
		for each in titles:
			s = s + '<tr><td><a href="%s">%s</a></td></tr>\n' % (each[1], each[0])

		s = s + self._htmlBottom

		f.write (s)
		f.close()

# Check if arguments are right
if (len(sys.argv) <> 3):
	print "Error\n\njack.py fichero_formato_intermedio prefijo_salida_html"
	sys.exit(-1)

ficin = sys.argv[1] # Middle format
fichtml = sys.argv[2] # Prefix for HTML files

bat = jack (ficin, fichtml)
bat.parse()
