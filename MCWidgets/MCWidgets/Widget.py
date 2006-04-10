# -*- coding: latin1 -*-

'''

Widget - Base de los widgets de MCWidgets

'''

from MCWidgets.Escape import html_escape
from MCWidgets.Form import WidgetInvalidArgs, WidgetWithoutNotification

class Widget(object):

    def __init__(self, form, name, args):
        import weakref, copy

        self._form = weakref.ref(form)
        self._name = name
        self._args = copy.copy(args)
        self._attrs = {}

        self._check_args()

    def get_arg(self, name, default = None):
        '''get_arg(name, default = None) -> str

        Devuelve el valor del argumento pedido. Si no lo encuentra en el 
        widget, lo buscará en el formulario. Si tampoco está ahí, devolverá
        defualt.
        '''

        if self._args.has_key(name):
            return self._args[name]

        return self.get_form().get_arg(name, default)

    def set_arg(self, name, value):
        '''set_arg(name, value)

        Establece el valor del argumento en el widget.'''

        self._args[name] = value

    def get_type(self):
        '''get_type() -> str

        Devuelve el nombre del tipo del widget. Cada tipo debe
        definir un nombre que garantice que sea único'''

        raise NotImplementedError

    def get_form(self):
        '''get_form() -> Form

        Devuelve el formulario al que pertenece el widget'''
        return self._form()

    def validate_widget(self):
        '''validate_widget() -> list

        Devuelve una lista con los errores encontrados al validar
        los datos de este widget.
        '''

        return []

    def initialize_type(self):
        '''initialize_type()

        Se llama para inicializar el tipo de widget en el formulario. Si se
        definen varios widgets de este mismo tipo, sólo se llamará una vez.
        '''

        pass

    def initialize_widget(self):
        '''initialize_widget()

        Inicializa el widget. Se llama por cada widget.
        '''

        pass

    def remove_widget(self):
        '''remove_widget()

        Invocado cuando el widget se va a eliminar del formulario.
        Ojo, esta función no se invoca siempre que el formulario se cierra,
        tan solo si se elimina el widget mediante Form.remove_widget
        '''

        pass

    def get_variable_names(self):
        '''get_variable_names() -> list

        Devuelve una lista de las variables usadas por el widget. Es útil
        cuando, por ejemplo, se tiene que generar un formulario "invisible"
        con todas las variables usadas en los widgets'''

        return [ self.get_html_name() ]

    def get_calc_html_attrs(self):
        '''get_calc_html_attrs() -> dict

        Devuelve un diccionario con los atributos a poner en 
        la etiqueta.'''

        r = { 
            'id': self.get_html_id(),
            'name': self.get_html_name(),
        }

        if self.get_arg('disabled', 0): r['disabled'] = None
        if self.get_arg('readonly', 0): r['readonly'] = None
        if self.get_arg('class', 0):    r['class'] = self.get_arg('class')
        a = self.get_arg('style', None)
        if a is not None:
            r['style'] = a

        return r

    def get_name(self):
        '''get_name() -> str

        Devuelve el nombre del widget'''

        return self._name

    def get_html_name(self):
        '''get_name() -> str

        Devuelve el nombre de la variable HTML del widget'''

        n = self.get_arg('name', None)
        if n is None:
            n = self._make_var_name('value')
        return n

    def get_value(self):
        '''get_value() -> str

        Devuelve el valor del widget, ya transformado.'''

        return self.get_form()._get_raw_form_values().get(self.get_html_name(), None)

    def get_html_id(self):
        '''get_html_id() -> str

        Devuelve el identificador el widget en HTML.'''

        return '_id_' + self.get_form().get_name() + '_' + self.get_name()

    ID = property(get_html_id, None, None)

    def render(self):
        '''render() -> str

        Devuelve una cadena con el HTML del widgets'''

        import Utils
        html = '<input %s />' % Utils.html_dict_attrs(self.get_calc_html_attrs())

        if self.get_arg('tabindex', None) == 1:
            html += '<script>document.getElementById("%s").focus()</script>' % self.get_html_id()

        return html

    def get_label(self):
        '''get_label() -> str

        Devuelve la etiqueta para este widget
        '''

        return '<label for="%s">%s</label>' % (
            self.get_html_id(), 
            self._args.get('label', self.get_name())
        )

    def update_widgets_list(self, widgets):
        '''update_widgets_list(widgets)

        El formulario invoca esta función cuando cada vez que se añade un 
        widget. El argumento widgets es un diccionario con todo los widgets
        que hay definidos.'''

        pass

    def request_notification(self, event, calljs):
        '''request_notification(event, calljs)

        Registra la llamada a JavaScript indicada en calljs cuando ocurre
        el evento indicado.'''

        raise WidgetWithoutNotification, 'The widget "%s" does not support notification' % self.get_type()

    def _check_args(self):
        '''_check_args()

        Comprueba si la lista de argumentos que ha recibido es correcta.'''

        required, optional = self.get_args_spec()

        for arg in required:
            if arg not in self._args:
                raise WidgetInvalidArgs, 'Required argument "%s" did not send for %s (%s)' % (arg, self.get_name(), self.get_type())

        l = required + optional
        for arg in self._args.keys():
            if arg not in l:
                raise WidgetInvalidArgs, 'Invalid argument "%s" for %s (%s)' % (arg, self.get_name(), self.get_type())

    def get_args_spec(self):
        '''get_args_spec() -> [required, optional]

        Devuelve una lista con dos elementos. Cada elemento es una lista de
        argumentos. La primera indica los argumentos obligatorios, y la segunda
        los argumentos opcionales'''

        return [], ['class', 'readonly', 'disabled', 'name', 'htmlhelp', 'tabindex', 'label', 'style']

    def get_validation_js_info(self):
        '''get_validation_info() -> dict

        Devuelve una lista de diccionarios con los datos para que el formulario
        sepa cómo validar sus datos en el cliente. Si el widget no necesita
        validación de datos, devolverá una lista vacía.
        '''

        return []

    def _make_var_name(self, varname):
        '''make_var_name (varname) -> str

        Crea un nombre para una variable dentro del widget.'''

        return self.get_form()._make_var_name(self.get_name(), varname)

    def _merge_dicts(self, *dicts):
        '''_merge_dicts(*dicts) -> dict

        Mezcla los diccionarios que recibe por parámetro. Las claves
        de los últimos tienen preferencia sobre la de los primeros'''
        d = {}
        for i in dicts:
            d.update(i)
        return d

