#
# -*- coding: latin1 -*-

'''

Form - Formulario de MCWidgets

'''

from MCWidgets.Escape import html_escape


class WidgetError(Exception): pass
class WidgetNotFound(WidgetError): pass
class WidgetTypeNotValid(WidgetError): pass
class WidgetDuplicated(WidgetError): pass
class WidgetInvalidArgs(WidgetError): pass
class WidgetWithoutNotification(WidgetError): pass

class Form:

    def __init__(self, form_name, args = {}):

        self._args = args.copy()
        self._props = {}
        self._widgets = {}
        self._form_name = form_name
        self._initialized_types = []
        self._form_values = {}

        self.__included_js = []
        self.__included_css = []

        # Añadir los ficheros necesarios para la validación.

        self._add_js_file('util.js')
        self._add_js_file('validate.js')
        self._add_css_file('validate.css')


    # Argumentos. Se usan para definir parámetros comunes en los
    # widgets. Además, cada widget tiene sus propios argumentos.

    def get_arg(self, arg, default = None):
        '''get_arg(arg, default = None) -> str

        Devuelve el argumento pedido. Si no lo encuentra, devuelve default'''

        return self._args.get(arg, default)

    def set_arg(self, arg, value):
        '''set_arg(arg, value)

        Cambia el valor del argumento indicado'''
        self._args[arg] = value


    # Propiedades. Se usan para los widgets puedan mandar datos
    # complementarios al que dibujará el formulario

    def add_prop(self, prop, value, unique = False):
        '''add_prop(prop, value)

        Añade el texto indicado por value a la propiedad. 
        
        Si unique es verdadero, el texo sobrescribirá el valor
        actual de la propiedad. Si es falso, se añadirá al final.
        '''

        if unique:
            self._props = value
        else:
            self._props[prop] = self._props.get(prop, '') + value

    def get_prop(self, prop, default = ''):
        '''get_prop(prop, default = '') -> str

        Devuelve el valor de la propiedad. Si no la encuentra devuelve
        el valor de default. '''

        return self._props.get(prop, default)

    def list_props(self):
        '''list_props() -> list

        Devuelve una lista de las propiedades definidas'''

        return self._props.keys()


    # Validación de valores.

    def validate_widget(self, widget):
        '''validate_widget(widget) -> list

        Devuelve una lista con los errores encontrados en el valor
        del widget. Si no hay fallos devuelve una lista vacía'''

        try:
            w = self._widgets[widget]
        except KeyError:
            raise WidgetNotFound, 'Widget %s not found' % widget

        return w.validate_widget()

    def validate_form(self):
        '''validate_form() -> dict

        Devuelve un diccionario con los errores encontrados en los widgets.
        Las claves del diccionario serán los nombres de los widgets, y los 
        valores, listas con los errores.
        
        Si no encuentra ningún error, devolverá un diccionario vacío'''

        errors = {}
        for name, widget in self._widgets.items():
            r = widget.validate_widget()
            if r:
                errors[name] = r

        return errors


    # Manipular la lista de widgets

    def add_widget(self, widget_type, name, args = {}):
        '''add_widget(widget_type, name, args = {})

        Añade un widget al formulario, del tipo widget_type. 

        widget_type debe ser una clase derivada de Widget.
        name se usa para referirse al widget, o una cadena
        para buscar en el paquete MCWidgets.Widgets
        '''

        if isinstance(widget_type, str):
            import MCWidgets.Widgets
            widget_type = getattr(MCWidgets.Widgets, widget_type)

        import Widget
        if not issubclass(widget_type, Widget.Widget):
            raise WidgetTypeNotValid, 'Widget type %s is not valid' % type

        if name in self._widgets:
            raise WidgetDuplicated, 'Widget "%s" have been already added' % name

        w = widget_type(self, name, args)
        self._widgets[name] = w

        # Incializar el tipo, si aún no lo está
        widget_type = w.get_type()
        if not self._type_initialized(widget_type):
            w.initialize_type()
            self._type_mark_initialized(widget_type)

        # Y el propio widget
        w.initialize_widget()

        # Decirle a los widgets que hay uno nuevo 
        for widget in self._widgets.values():
            widget.update_widgets_list(self._widgets)

    def remove_widget(self, name):
        '''remove_widget(name)

        Elimina un widget del formulario. Ojo, use este método sólo si
        sabe lo que está haciendo. Eliminar widgets puede causar problemas
        de dependencias con otros que lo estén usando.
        '''

        try:
            widget =  self._widgets[name]
        except KeyError:
            raise WidgetNotFound, 'Widget %s not found' % name

        # Notificar al propio widget que se va a eliminar del
        # formulario
        widget.remove_widget()

        del self._widgets[name]

        # Y notificar al resto del cambio
        for widget in self._widgets.values():
            widget.update_widgets_list(self._widgets)

    def has_widget(self, name):
        '''has_widget(name) -> bool

        Verdadero si el widget del nombre indicado está definido'''

        return self._widgets.has_key(name)

    def get_widget(self, name):
        '''get_widget(name) -> widget

        Devuelve el widget solicitado
        '''
        try:
            return self._widgets[name]
        except KeyError:
            raise WidgetNotFound, 'Widget %s not found' % name

    def get_widgets(self):
        '''get_widgets() -> dict

        Devuelve un diccionario con todos los widgets del formulario. Las 
        claves serán los nombres de los widgets y los valores el objeto
        que lo representa.
        '''
        return dict(self._widgets)


    # Valores del formulario. Los valores serán aquellos que
    # devuelvan los propios widgets.

    def define_form_values(self, values):
        '''define_form_values(values)

        Estable (mediante un diccionario) los valores que usarán los widgets
        como fuente.

        Para obtener los datos validados y transformados de los widgets, use
        get_form_value y get_form_values'''

        import copy
        self._form_values = copy.copy(values)

    def _get_raw_form_values(self):
        '''_get_raw_form_values() -> dict

        Devuelve el diccionario usado como fuente para los widgets'''

        return self._form_values

    def get_form_values(self):
        '''get_form_values() -> dict

        Devuelve un diccionario con los valores de los widgets. Las claves
        serán el nombre del widget, y el valor lo que devuelve el propio
        widget.'''

        r = {}
        for name, widget in self._widgets.items():
            r[name] = widget.get_value()
        return r

    def get_form_value(self, name):
        '''get_form_value(name) -> object

        Devuelve el valor de un widget.'''

        try:
            w = self._widgets[name]
        except KeyError:
            raise WidgetNotFound, 'Widget %s not found' % name

        return w.get_value()


    # Renderizar los widgets

    def render_widget(self, widget):
        '''render_widget(widget) -> str

        Devuelve una cadena con el código HTML del widget pedido'''

        try:
            w = self._widgets[widget]
        except KeyError:
            raise WidgetNotFound, 'Widget %s not found' % widget

        return w.render()


    def get_form_attrs(self):
        '''get_form_attrs() -> dict

        Devuelve los atributos para el formulario actual.'''

        # Obtener la información para validad de cada widget
        validation_info = []
        for widget in self._widgets.values():
            validation_info += widget.get_validation_js_info()


        import json
        return {
            'method': 'post',
            'name': self.get_name(),
            'action': self.get_url_action(),
            'onsubmit': 'try { %s; } catch(e) {}; return mcw_form_validate(%s);' % (
                self.get_prop('before_submit', '0'),
                json.write(validation_info))
        }

    def auto_render(self):
        '''auto_render() -> str

        Devuelve una cadena con el HTML de todo el formulario
        '''

        from MCWidgets.Utils import html_dict_attrs
        res = '<form %s>\n<table>\n' % html_dict_attrs(self.get_form_attrs())

        widgets = self._widgets.keys()
        widgets.sort()
        for w in widgets:
            w = self._widgets[w]
            res += '<tr><td>' + w.get_label() + '</td>'
            res += '<td>' + w.render() + '</td></tr>\n'
        return res + '</table>\n<input type="submit" />\n</form>\n'


    # Funciones internas

    def get_url_action(self):
        '''get_url_action() -> str

        Devuelve la URL a la que se mandará el formulario'''

        return self._args.get('url_action', '')

    def get_name(self):
        '''get_name() -> str

        Devuelve el nombre del formulario'''

        return self._form_name

    def _get_url_static_files(self):
        '''_get_url_static_files() -> str

        Devuelve la url donde están los ficheros estáticos para,
        los widgets, como CSS, JavaScript, imágenes, etc'''

        return self._args.get('url_static_files', '/staticmcw/')

    def _make_var_name(self, widget, varname):
        '''_make_var_name (widget, varname) -> str

        Devuelve el nombre de variable para el widget. La idea de esta
        función es que los widgets la usen para generar los nombres de sus
        variables, de manera que se asegure que no se pisan variables entre
        ellos.'''

        # damos por hecho de que el nombre de la variables 
        # no contiene caracteres problemáticos
        return '_'.join([self._form_name, widget, varname])

    def _type_initialized(self, typename):
        '''_type_initialized (type) -> bool

        Devuelve True si el tipo de widget indicado ya está
        inicializado'''

        return typename in self._initialized_types

    def _type_mark_initialized(self, typename):
        '''_type_mark_initialized (typename) 

        Marca el tipo indicado como inicializado. Si ya estaba
        inicializado no hace nada'''

        l = self._initialized_types
        if typename not in l:
            l.append(typename)


    def _add_js_file(self, url):
        '''_add_js_file(url)

        Añade a la cabecera una etiqueta para cargar el fichero indicado. La URL
        será relativa a donde están todos los ficheros estáticos de MCWidgets.
        
        Si la URL ya había sido incluido, sale sin hacer nada.'''

        if url in self.__included_js:
            return

        self.__included_js.append(url)
        self.add_prop(
            'header', 
            '<script src="%s/%s"></script>\n' % 
                (self._get_url_static_files(), url))

    def _add_css_file(self, url):
        '''_add_css_file(url)

        Añade a la cabecera una etiqueta para cargar el fichero indicado. La URL
        será relativa a donde están todos los ficheros estáticos de MCWidgets.
        
        Si la URL ya había sido incluido, sale sin hacer nada.'''

        if url in self.__included_css:
            return

        self.__included_css.append(url)
        self.add_prop(
            'header', 
            '<link href="%s/%s" type="text/css" rel="stylesheet" />\n' % 
                (self._get_url_static_files(), url))


class FormTemplate:
    '''FormTemplate

    Esta clase se usa para poder usarse en plantillas. Funciona como 
    un diccionario para acceder a los widgets del formulario. Cuando
    se accede a él por clave, llama al render del widget pedido.

        ft = FormTemplate(form)
        return ft['widget']

    Es equivalente al 

        return form.render_widget('widget')

    A través del método W()

    La idea es poder usarlo fácilmente desde plantillas.

        $form.nombre       -> form.render_widget("nombre")
        $form.W.nombre     -> form.get_widget("nombre")
    '''

    def __init__(self, form):
        self.__form = form
        self.__cache = {}

    def W(self):
        return self.__form.get_widgets()

    def form_attributes(self):
        from MCWidgets.Utils import html_dict_attrs
        return html_dict_attrs(self.__form.get_form_attrs())

    def __getattr__(self, wid):
        if not self.__cache.has_key(wid):
            try:
                self.__cache[wid] = self.__form.render_widget(wid)
            except:
                import traceback, sys
                traceback.print_exc(file = sys.stderr)
                raise
        return self.__cache[wid]

    def get_name(self):
        return (self.__form.get_name())
