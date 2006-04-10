# -*- coding: latin1 -*-

from __future__ import generators

from MCWidgets.Widgets.BaseJS import BaseJS

class RadioButton(BaseJS):

    def get_type(self):
        return 'MCWidgets.RadioButton'

    def get_args_spec(self):
        req, opt = BaseJS.get_args_spec(self)
        return (req + ['options']), (opt + ['initial_value', 'separator'])

    def get_calc_html_attrs(self):
        return self._merge_dicts (
            BaseJS.get_calc_html_attrs(self),  { 'type' : 'radio',  })

    def get_value(self):
        v = BaseJS.get_value(self)
        if v is None:
            v = self.get_arg('initial_value', None)
        return v

    def render_options(self):
        import MCWidgets.Utils
        import MCWidgets.Escape

        curvalue = self.get_value()

        for opt in self._get_options():
            attrs = self.get_calc_html_attrs().copy()
            attrs['value'] = opt['value']
            attrs['id'] = opt['id']

            if curvalue == opt['value']:
                attrs['checked'] = None

            yield '<input %s /><label for="%s">%s</label>' % (
                MCWidgets.Utils.html_dict_attrs(attrs),
                opt['id'], opt['label'])

    def _get_options(self):
        import itertools
        count = itertools.count()
        return [
            {
                'id': self._make_var_name('__opt_id_%s' % count.next()),
                'label': val,
                'value': key,
            } for (key, val) in self.get_arg('options')]

    def render(self, sep = None):
        return (sep or self.get_arg('separator', '<br />')).join(self.render_options())

    def calljs_getvalue(self):
        import json
        return 'mcw_radio_get_value(%s)' % json.write([o['id'] for o in self._get_options()])

    def initialize_type(self):
        self.get_form()._add_js_file('radiobutton.js')
