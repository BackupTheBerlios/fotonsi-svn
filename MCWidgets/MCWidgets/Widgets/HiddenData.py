# -*- coding: latin1 -*-

from MCWidgets.Widgets.BaseJS import BaseJS
import json

class HiddenData(BaseJS):

    def get_type(self):
        return 'MCWidgets.HiddenData'

    def get_value(self):
        fv = self.get_form()._get_raw_form_values()
        if fv.has_key(self.get_html_name()):
            return json.read(fv[self.get_html_name()])
        return self.get_arg('initial_value', None)

    def get_args_spec(self):
        req, opt = BaseJS.get_args_spec(self)
        return req, (opt + ['initial_value'])

    def get_calc_html_attrs(self):
        return self._merge_dicts (
            BaseJS.get_calc_html_attrs(self), 
            {
                'type' : 'hidden', 
                'value': json.write(self.get_value()),
            })
