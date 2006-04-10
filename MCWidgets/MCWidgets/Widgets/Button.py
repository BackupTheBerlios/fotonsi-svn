# -*- coding: latin1 -*-

from MCWidgets.Widgets.BaseJS import BaseJS

class Button(BaseJS):

    def get_type(self):
        return 'MCWidgets.Button'

    def get_value(self):
        # Para el botón, devuelve verdadero o falso si se ha pulsado este botón.
        return BaseJS.get_value(self) is not None

    def get_args_spec(self):
        req, opt = BaseJS.get_args_spec(self)
        return req, opt + ['label', 'submit']

    def get_calc_html_attrs(self):
        calcdict = self._merge_dicts (
            BaseJS.get_calc_html_attrs(self), 
            {
                'type' : self.get_html_type(), 
                'value': self.get_arg('label', self.get_name())
            })

        return calcdict

    def get_html_type(self):
        if self.get_arg('submit', True):
            return 'submit'
        return 'button'
