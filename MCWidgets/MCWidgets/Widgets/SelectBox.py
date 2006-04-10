# -*- coding: latin1 -*-

from MCWidgets.Escape import html_escape, js_str_escape
from MCWidgets.Widgets.BaseJS import BaseJS

class SelectBox(BaseJS):

    def get_type(self):
        return 'MCWidgets.SelectBox'

    def get_value(self):
        v = BaseJS.get_value(self)
        if v is None:
            return self.get_arg('selected', [])

        if not isinstance(v, list):
            v = [v]

        return v

    def get_calc_html_attrs(self):
        calcdict = BaseJS.get_calc_html_attrs(self)

        for at in ('size', 'multiple', 'readonly'):
            a = self.get_arg(at, None)
            if a is not None: 
                calcdict[at] = str(a)

        if 'readonly' in calcdict:
            calcdict['readonly'] = None

        return calcdict

    def validate_widget(self):
        errors = []
        values = [x[0] for x in self.get_arg('options', [])]
        for e in self.get_value():
            if e not in values:
                errors.append('Value "%s" is not a valid value' % e)
        return errors

    def get_args_spec(self):
        req, opt = BaseJS.get_args_spec(self)
        return (req + ['options'], 
                opt + ['selected', 'sync_with', 'ajax_url', 
                       'headoption', 'multiple', 'size'])

    def render(self):

        options = []
        selected = self.get_value()

        ho = self.get_arg('headoption', None)
        if ho is not None and not selected:
            options.append('    <option value="null" style="font-style: italic" disabled selected>%s</option>' % ho)

        for value, text in self.get_arg('options', []):
            s = ''
            if value in selected: s = ' selected'

            options.append('    <option value="%s"%s>%s</option>' % 
                            (html_escape(value), s, html_escape(text)))

        from MCWidgets.Utils import html_dict_attrs as hda
        result = '<select %s>%s</select>' % (
            hda(self.get_calc_html_attrs()), '\n'.join(options))

        if self.get_arg('tabindex', None) == 1:
            result += '<script>document.getElementById("%s").focus()</script>' % self.get_html_id()

        return result

    def calljs_getvalue(self):
        return 'document.getElementById("%(i)s").options[document.getElementById("%(i)s").selectedIndex].value' % \
            {'i': self.get_html_id() }

    def initialize_type(self):
        form = self.get_form()
        form._add_js_file('selectbox.js')
        form._add_js_file('util.js')
        form._add_js_file('dojoio.js')

    def initialize_widget(self):

        sync_with = self.get_arg('sync_with', None)
        ajax = self.get_arg('ajax_url', None)
        if None not in (sync_with, ajax):
            import json
            from MCWidgets.Widget import Widget

            if not isinstance(sync_with, Widget):
                sync_with = self.get_form().get_widget(sync_with)

            sync_with.request_notification(
                'change', 
                'mcw_sb_ajax_update("%s", "%s", %s, %s)' % (
                    self.get_html_id(),
                    ajax, 
                    sync_with.calljs_getvalue(),
                    json.write(self.get_arg('headoption'))))
