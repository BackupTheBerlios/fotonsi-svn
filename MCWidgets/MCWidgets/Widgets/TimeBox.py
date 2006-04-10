# -*- coding: latin1 -*-

from MCWidgets.Widgets import TextBox

import re
fecha_larga = re.compile(r'\d+-\d+-\d+ (\d+:\d+:\d+)\.\d+')

class TimeBox(TextBox):

    def get_type(self):
        return 'MCWidgets.TimeBox'

    def get_validation_js_info(self):
        r = TextBox.get_validation_js_info(self)
        me = 'document.getElementById("%s")' % self.get_html_id()

        return r + [{
            'msg': 'Invalid time',
            'validate': '(/^((2[0-3])|([01]?[0-9])):[0-5]?[0-9]:([0-5]?[0-9])?$/.exec(%s))' % self.calljs_getvalue(),
            'onselect': me + '.focus()',
            'markitem': self.get_html_id()
        }]

    def get_calc_html_attrs(self):
        at = TextBox.get_calc_html_attrs(self)
        if ' ' in at['value']:
            m = fecha_larga.match(at['value'])
            if m:
                at['value'] = m.group(1)
        return at
