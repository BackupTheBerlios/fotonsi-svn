
import sys
sys.path.append('..')

from MCWidgets.Widgets import *
from MCWidgets.Form import Form

form = Form('f')
form.add_widget(TextBox, 'texto', {
    'onfocus': '''if (this.valu == "yes") { alert("oh s"); }'''
    })
form.add_widget(SelectBox, 'select', {
    'options': [('1', 'uno'), ('2', 'dos'), ('3', 'tres')],
    'selected': ['2'],
    'onchange': 'actualizar_tema(this)'
    })


form.add_widget(Numeric, 'numero', {'initial_value': '100'})


print form.render_widget('texto')
print form.render_widget('select')
print form.render_widget('numero')
