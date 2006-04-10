# -*- coding: latin1 -*-

from MCWidgets.Widgets.BaseJS import BaseJS
from MCWidgets.Form import html_escape
from MCWidgets import Utils

class TextBox(BaseJS):

    def get_type(self):
        return 'MCWidgets.TextBox'

    def get_value(self):
        v = BaseJS.get_value(self)

        if v is None:
            v = self.get_arg('initial_value', '')

        if v is None:
            v = ''

        if type(v) not in (str, unicode):
            v = str(v)

        if self.get_arg('trim_spaces'):
            v = v.strip()

        return v

    def get_calc_html_attrs(self):
        calcdict = self._merge_dicts (
            BaseJS.get_calc_html_attrs(self), 
            {
                'type' : 'text', 
                'value': self.get_value()
            })

        if self.get_arg('trim_spaces'):
            calcdict['onblur'] = 'mcw_tb_trim_spaces(this);' + calcdict.get('onblur', '')

        for at in ('size', 'maxlength', 'class',):
            a = self.get_arg(at, None)
            if a is not None: 
                calcdict[at] = a

        if self.get_arg('password', False):
            calcdict['type'] = 'password'

        return calcdict

    def get_args_spec(self):
        req, opt = BaseJS.get_args_spec(self)
        return req, opt + [
            'size', 'nonempty', 'maxlength', 'class', 'initial_value', 
            'sync_with', 'sync_map', 'trim_spaces', 'password']

    def initialize_widget(self):
        self.get_form()._add_js_file('textbox.js')
        self.get_form()._add_js_file('prototype-1.2.0.js')

        sync_with = self.get_arg('sync_with', None)
        if sync_with is not None:
            import json

            sync_with.request_notification('change',
                'mcw_tb_sync_widget(%s, "%s", %s)' % (
                    sync_with.calljs_getvalue(),
                    self.get_html_id(),
                    json.write(self.get_arg('sync_map', False))))

    def get_validation_js_info(self):
        r = BaseJS.get_validation_js_info(self)

        if self.get_arg('nonempty', False):
            me = 'document.getElementById("%s")' % self.get_html_id()
            r.append({
                'validate': me + '.value != ""',
                'onselect': me + '.focus()',
                'msg': 'Can not be empty'
            })

        return r
