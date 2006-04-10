

from MCWidgets.Widgets.BaseJS import BaseJS

class PlainHtml(BaseJS):

    def get_type(self):
        return 'MCWidgets.PlainHtml'

    def _make_var_value_id(self):
        return self._make_var_name('widget_value')

    def get_value(self):
        val = BaseJS.get_value(self)
        if val is None: val = str(self.get_arg('initial_value', ''))
        return val

    def get_args_spec(self):
        req, opt = BaseJS.get_args_spec(self)
        return req, opt + ['initial_value']

    def render(self):
        from MCWidgets.Utils import html_dict_attrs
        return (
                
            '<span %s>%s</span>' % (
                html_dict_attrs(self.get_calc_html_attrs()),
                self.get_value()) +

            '<input %s />' % html_dict_attrs({
                    'type': 'hidden',
                    'name': self.get_html_name(),
                    'id': self._make_var_value_id(),
                    'value': self.get_value(),
                })
            )

    def calljs_setvalue(self, new_value):
        import json
        return 'mcw_ph_set_value(%s, %s, %s)' % (
                    json.write(self._make_var_value_id()),
                    json.write(self.get_html_id()),
                    new_value)

    def initialize_type(self):
        self.get_form()._add_js_file('plainhtml.js')
