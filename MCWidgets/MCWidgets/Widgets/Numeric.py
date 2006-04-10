# -*- coding: latin1 -*-

from MCWidgets.Widgets.TextBox import TextBox
from MCWidgets.Widgets.BaseJS import BaseJS 

class Numeric(TextBox):

    def get_type(self):
        return 'MCWidgets.Numeric'

    def initialize_type(self):
        form = self.get_form()
        form._add_js_file('textbox.js')
        form._add_js_file('prototype-1.2.0.js')
                         

    def initialize_widget(self):
        import json
        self.get_form().add_prop('header', '''
            <script>
                window['__mcw__separatos__%s'] = %s;
            </script>''' % (self.get_html_id(), json.write(self._locale_conv())))

    def get_args_spec(self):
        req, opt = TextBox.get_args_spec(self)
        return req, opt + ['separators']

    def get_value(self):

        # Si viene por el argumento initial_value, lo tomamos como que
        # es formato máquina. Si viene por las variables llegadas
        # por formulario, es formato humano

        v = BaseJS.get_value(self)
        if v is None:
            return self.get_arg('initial_value', '0')

        v = self._number_human_to_mac(v)

        try:
            v = int(v)
        except ValueError:
            try:
                v = float(v)
            except ValueError:
                v = 0

        return v

    def validate_widget(self):
        errors = []

        v = self._number_human_to_mac(BaseJS.get_value(self) or '0')
        if v is not None:
            try:
                # Para tomarlo como un valor, debe al menos poder ser convertido a real
                v = float(v)
            except ValueError:
                errors.append('Invalid number')

        return errors

    def get_calc_html_attrs(self):
        calcdict = TextBox.get_calc_html_attrs(self)

        html_id = self.get_html_id()
        calcdict['onfocus'] = ('mcw_numeric_focus("%s");' % html_id) + calcdict.get('onfocus', '')
        calcdict['onblur'] = ('mcw_numeric_blur("%s");' % html_id) + calcdict.get('onblur', '')
        calcdict['value'] = self._number_mac_to_human(str(self.get_value()))
        calcdict['align'] = 'right'

        return calcdict

    def _locale_conv(self):
        '''localeconv() ->  (str, str)

        Devuelve una tupla de dos elementos, donde el primero es el símbolo a usar
        como separador decimal, y el segundo como separador de miles'''

        # Usar la configuración regional para separador de miles y decimal
        #import locale
        #lc = locale.localeconv()

        return self.get_arg('separators', (',', '.'))

    def _number_human_to_mac(self, v):
        '''_number_human_to_mac(number) -> str

        Convierte un número de formato humano a formato máquina'''

        decimal_point, thousands_sep = self._locale_conv()
        return str(v).replace(thousands_sep, '').replace(decimal_point, '.')

    def _number_mac_to_human(self, v):
        '''_number_mac_to_human(number) -> str

        Convierte un número de formato máquina a formato humano'''

        import re

        decimal_point, thousands_sep = self._locale_conv()

        v = str(v)
        if '.' not in v: v += '.'
        p_int, p_dec = v.split('.')
        p_int = reverse(thousands_sep.join(re.findall('.{1,3}', reverse(p_int))))
        if p_dec:
            return p_int + decimal_point + p_dec
        return p_int

    def get_validation_js_info(self):
        r = TextBox.get_validation_js_info(self)
        me = 'document.getElementById("%s")' % self.get_html_id()

        return r + [{
            'msg': 'Invalid number',
            'validate': 'isNaN(%s)' % self.calljs_getvalue(),
            'onselect': me + '.focus()',
            'markitem': self.get_html_id()
        }]

    def calljs_getvalue(self):
        return 'mcw_numeric_get_value("%s")' % self.get_html_id()


# Hacer la función reverse() según la versión de python.
# Si estamos con una 2.3+, usar el método del propio lenguaje
import sys
if sys.version_info[0] >= 2 and sys.version_info[1] >= 3:
    reverse = lambda x: x[::-1]
else:
    def reverse(l):
        l = list(l)
        l.reverse()
        return ''.join(l)

