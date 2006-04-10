# -*- coding: latin1 -*-

from MCWidgets.Widgets.MultiValues import MultiValues
from MCWidgets.Escape import html_escape

class MultiSelect(MultiValues):

    def get_type(self):
        return 'MCWidgets.MultiSelect'

    def get_args_spec(self):
        req, opt = MultiValues.get_args_spec(self)
        return req + ['option_template'], opt

    def render_input(self):
        s = '<select id="%s">\n' % self._get_input_name()
        key = self.get_arg('key')
        tpl = self.get_arg('option_template')
        for item in self.get_arg('source'):
            s += '   <option value="%s">%s</option>\n' % (
                html_escape(str(item[key])),
                html_escape(tpl % item))
        return s + '</select>\n'

    def calljs_value_to_add(self):
        return 'document.getElementById("%(id)s").options[document.getElementById("%(id)s").selectedIndex].value' % \
                { 'id': self._get_input_name() }

