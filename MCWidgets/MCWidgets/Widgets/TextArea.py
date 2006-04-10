# -*- coding: latin1 -*-

from MCWidgets.Widgets import TextBox
from MCWidgets.Escape import html_escape

class TextArea(TextBox):

    def get_type(self):
        return 'MCWidgets.TextArea'

    def get_calc_html_attrs(self):
        calcdict = TextBox.get_calc_html_attrs(self)

        try:
            del calcdict['value']
        except KeyError:
            pass

        for at in ('rows', 'cols'):
            a = self.get_arg(at, None)
            if a is not None: 
                calcdict[at] = a

        return calcdict

    def get_args_spec(self):
        req, opt = TextBox.get_args_spec(self)
        return req, opt + ['rows', 'cols']

    def render(self):
        from MCWidgets.Utils import html_dict_attrs
        return '<textarea %s />%s</textarea>' % (
            html_dict_attrs(self.get_calc_html_attrs()),
            html_escape(self.get_value()))
