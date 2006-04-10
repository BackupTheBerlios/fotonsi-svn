#!/usr/bin/python
# -*- coding: latin1 -*-

# Dependencies

import sys

try:
    import json
except ImportError:
    print 'Error de dependencias. Hay que instalar Json, disponible en'
    print '  http://sourceforge.net/projects/json-py/ o '
    print '  https://laser:4081/svn/foton/javascript/json-py/json.py'
    sys.exit(1)

from distutils.core import setup

setup(name = 'MCWidgets', version = "0.1",
    author = 'Fotón Sistemas Inteligentes',
    author_email = 'foton@foton.es',
    url = 'http://www.foton.es',
    license = 'GNU General Public License (GPL)',
    description = 'MCWdigets',
    packages = ['MCWidgets', 'MCWidgets.Widgets'],
    #scripts = [],
)

