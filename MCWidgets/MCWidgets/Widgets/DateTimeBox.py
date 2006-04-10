# -*- coding: latin1 -*-

from MCWidgets.Widget import Widget
from MCWidgets.Widgets.DateBox import DateBox
from MCWidgets.Widgets.TimeBox import TimeBox
from MCWidgets.Widgets.TextBox import TextBox

class DateTimeBox(TextBox):

    def get_type(self):
        return 'MCWidgets.DateTimeBox'

    def get_value(self):
        # Devolver una cadena que represente la fecha.
        # Cogemos la hora del TimeBox y la fecha del DateBox
        form = self.get_form()
        ndate, ntime = self._make_widget_names()
        return '-'.join(map(str, form.get_widget(ndate).get_value()[:3])) + ' ' + form.get_widget(ntime).get_value()

    def initialize_widget(self):
        # crear los dos widget dentro del propio formulario
        form = self.get_form()
        ndate, ntime = self._make_widget_names()
        form.add_widget(TimeBox, ntime, {'initial_value': self.get_arg('initial_value', None)})
        form.add_widget(DateBox, ndate, {'initial_value': self.get_arg('initial_value', None)})

    def set_arg(self, arg, val):
        if arg == 'initial_value':
            form = self.get_form()
            ndate, ntime = self._make_widget_names()
            form.get_widget(ntime).set_arg('initial_value', val)
            form.get_widget(ndate).set_arg('initial_value', val)
        else:
            TextBox.set_arg(self, arg, val)

    def _make_widget_names(self):
       return self._make_var_name('date'), self._make_var_name('time')

    def render(self):
        form = self.get_form()
        ndate, ntime = self._make_widget_names()
        return form.render_widget(ntime) + ' ' + form.render_widget(ndate)

