#!/usr/bin/python

print 'Content-type: text/html\n'
print '<p>Pruebas del MCWidgets:</p> <ul>'

import os
for f in os.listdir('.'):
    if f.endswith('.cgi'):
        print '<li><a href="%(f)s">%(f)s</a></li>' % vars()

print '</ul>'
