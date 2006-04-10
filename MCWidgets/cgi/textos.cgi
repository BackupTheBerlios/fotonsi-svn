#!/usr/bin/python

print 'Content-type: text/html\n'
print '<p>Pruebas del MCWidgets:</p> <ul>'

from MCWidgets.Widgets import *
from MCWidgets.Form import Form

import cgi

form = Form('f')
fs = cgi.FieldStorage()
form.define_form_values(dict([(key, fs[key].value) for key in fs.keys()]))

form.add_widget(TextBox, 'texto', {
    'onblur': '''if (this.value == "yes") { alert("oh s"); }''',
    'label': 'Prueba de texto'
    })
form.add_widget(SelectBox, 'cosa_de_seleccion', {
    'options': [('1', 'uno'), ('2', 'dos'), ('3', 'tres')],
    'selected': ['2'],
    'onchange': 'actualizar_tema(this)'
    })

form.add_widget(Numeric, 'numero', {'initial_value': '100'})


print form.get_prop('header')

print form.auto_render()

try:
    print form.get_form_values()
except:
    import traceback, sys
    print "aa<pre>"
    traceback.print_exc(file=sys.stdout)
    print "</pre>"

