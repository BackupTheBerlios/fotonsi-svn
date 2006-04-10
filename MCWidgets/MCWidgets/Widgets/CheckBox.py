# -*- coding: latin1 -*-

from MCWidgets.Widgets.BaseJS import BaseJS

class CheckBox(BaseJS):

    def get_type(self):
        return 'MCWidgets.CheckBox'

    def get_value(self):
        formvalues = self.get_form()._get_raw_form_values()

        if self.get_arg('readonly', False):
            return self.get_arg('initial_value', 
                    formvalues.get(self._get_force_name(), '0') != '0')

        if formvalues.has_key(self._get_checker_name()):
            return formvalues.has_key(self.get_html_name())
            
        return self.get_arg('initial_value', False)

    def get_args_spec(self):
        req, opt = BaseJS.get_args_spec(self)
        return req, (opt + ['initial_value'])

    def get_calc_html_attrs(self):
        calcdict = self._merge_dicts (
            BaseJS.get_calc_html_attrs(self), 
            {
                'type' : 'checkbox', 
                'value': 'on'
            })

        if self.get_value():
            calcdict['checked'] = "yes"

        if self.get_arg('readonly', False):
            calcdict['disabled'] = None

        return calcdict

    def render(self):
        html = "<input type='hidden' name='%s' value='sent' />" % self._get_checker_name()
        if self.get_arg('readonly', False):
            html += "<input type='hidden' name='%s' value='%s' />" % (
                self._get_force_name(),
                int(bool(self.get_arg('initial_value', 0))))
        return BaseJS.render(self) + html

    def get_variable_names(self):
        return [self.get_html_name(), self._get_checker_name()]

    def _get_checker_name(self):
        return self._make_var_name('_cb_checker')

    def _get_force_name(self):
        return self._make_var_name('_cb_forcevalue')
