# -*- coding: latin1 -*-

from MCWidgets.Widgets.BaseJS import BaseJS

class DateBox(BaseJS):

    def get_type(self):
        return 'MCWidgets.DateBox'

    def initialize_type(self):
        form = self.get_form()
        form._add_js_file('calendar/main.js')
        form._add_js_file('calendar/es.js')
        form._add_css_file('calendar/theme-green.css')

    def get_value(self):
        import time
        raw_value = BaseJS.get_value(self)
        if raw_value:
            for fmt in self.get_formats():
                try:
                    return time.strptime(raw_value, fmt)
                except ValueError:
                    pass

        return self.get_initial_value() or time.localtime()

    def get_initial_value(self):
        import time
        v = self.get_arg('initial_value', None)
        if v is None: return None
        if isinstance(v, str):
            v = time.strptime(v.split()[0], '%Y-%m-%d')
        return v

    def get_args_spec(self):
        req, opt = BaseJS.get_args_spec(self)
        return req, opt + ['formats', 'initial_value']

    def get_calc_html_attrs(self):
        return self._merge_dicts (
            BaseJS.get_calc_html_attrs(self),
            {
                'value': self.get_value_as_string(),
            })

    def get_formats(self):
        return self.get_arg('formats', ['%d/%m/%Y', '%d/%m/%y', '%Y-%m-%d'])

    def get_value_as_string(self, fmt = None):
        import time
        
        if fmt is None:
            fmt = self.get_formats()[0]
        try:
            return time.strftime(fmt, self.get_value())
        except ValueError:
            return ''

    def render(self):
        if not self.get_arg('readonly', False):
            return (BaseJS.render(self) + 
                '''<input type="button" value="..." onclick="return showCalendar('%s', '%%d/%%m/%%Y');"/>''' %
                    self.get_html_id())
        else:
            return BaseJS.render(self)

