# -*- coding: latin -*-

from MCWidgets.Widgets.ListMultiCol import ListMultiCol

EXTRA_COLUM = '__LMW__extra_column'
EXTRA_COLUM_TPL = (
    '<input type="button" value="Borrar" onclick="%DELROW%"/>',
    '<input type="hidden" name="%s" value="%%N" />')

class ListMultiWidgets(ListMultiCol):

    def get_value(self):

        form = self.get_form()
        rows = form._get_raw_form_values().get(self._get_reg_items_id(), None)

        if not rows:
            return self.get_arg('data')

        rows = rows.split('\x01')
        # Recorre las filas (creando los widgets necesarios) para 
        # obtener los valores
        res = []
        columns = self.get_arg('columns')
        for row in rows:
            values = {}
            res.append(values)

            for col in columns:
                if col.has_key('widget'):
                    widget = col['widget']
                    name = self._make_widgetname(widget['name'], row)
                    if not form.has_widget(name):
                        args = self._append_args_from_template(
                            widget.get('args', {}), 
                            widget.get('template_args', {}), 
                            row, {})

                        form.add_widget(widget['type'], name, args)
                    values[widget['name']] = form.get_form_value(name)

        return res

    def get_args_spec(self):
        req, opt = ListMultiCol.get_args_spec(self)
        return req, opt + ['can_delete', 'can_delete_dyn', 'extra_html']

    def initialize_widget(self):

        form = self.get_form()
        columns = self.get_arg('columns')

        # Añadir en el before_submit la llamada para mandar el orden
        # de los campos
        form.add_prop('before_submit', 
            'mcw_lmw_before_submit("%s", "%s", "%s");' % (
                self.get_html_id(),
                self._get_counter_name(),
                self._get_reg_items_id()))

        # Crear los datos iniciales para los widgets

        row = 0
        data = []
        checkdelete = self.get_arg('can_delete', None)

        for row_data in self.get_value():
            cells = row_data.copy()
            row += 1
            for column in columns:
                if column.has_key('widget'):

                    widget = column['widget']
                    name = self._make_widgetname(widget['name'], row)

                    # Crear el widget que se usará para renderizar el que tiene el
                    # dato inicial. En la columna se guardará el HTML ya generado,
                    # y la clave para el mismo será el nombre del widget.

                    if not form.has_widget(name):
                        # Cambiar los argumentos pasados al widget para añadir el valor
                        # inicial

                        args = widget.get('args', {}).copy()
                        if not widget.get('no_initial_value'):
                            args[widget.get('key_initial', 'initial_value')] =  \
                                widget.get('filter_key', lambda x: x)(row_data[widget['name']])
                        args = self._append_args_from_template(
                            args, widget.get('template_args', {}), row, row_data)

                        form.add_widget(widget['type'], name, args)

                    cells[widget['name']] = lambda n = name: form.render_widget(n)


            # Añadir la columna extra, que incluye el botón de borrar (si lo lleva)
            # y los campos ocultos
            tpl_a, tpl_b = EXTRA_COLUM_TPL
            tpl_b %= self._get_counter_name()
            extra_html = self.get_arg('extra_html', '')

            if callable(checkdelete) and checkdelete(row_data):
                cells[EXTRA_COLUM] = tpl_a + tpl_b + extra_html
            else:
                cells[EXTRA_COLUM] = tpl_b + extra_html

            data.append(cells)

        # Una vez que hemos añadido todas las columnas, generamos el HTML.
        # Esto lo hacemos después de definir las columnas para que todos los widgets
        # queden definidos (y así pueda haber dependencias de unos con otros

        for row in data:
            for key, val in row.items():
                if callable(val):
                    row[key] = val()

        self.set_arg('data', data)

        # Crear la definición de las columnas, añadiendo la plantilla
        # para cada una
        columns = []
        for column in self.get_arg('columns'):
            if not column.has_key('widget'):
                columns.append(column)
            else:
                widget = column['widget']
                name = self._make_widgetname(widget['name'], "%N")
                args = self._append_args_from_template(
                                widget.get('args', {}), 
                                widget.get('template_args', {}), 
                                "%N", {})
                form.add_widget(widget['type'], name, args)
                template = lambda n = str(name): form.render_widget(n)

                columns.append({
                    'name': column['name'],
                    'key': widget['name'],
                    'html_escape': False,
                    'template': template,
                    'widget': widget,
                })


        # La columna extra, usada para incluir el botón borrar y datos 
        # de cada fila
        tpl_a, tpl_b = EXTRA_COLUM_TPL
        extra_template = ''
        if self.get_arg('can_delete_dyn', True):
            extra_template = tpl_a
        extra_template += (tpl_b % self._get_counter_name())
        columns.append({
            'name': '', 
            'template': extra_template,
            'key': EXTRA_COLUM,
            'as_template': True,
            'html_escape': False
        })

        # Una vez que hemos añadido todas las columnas, generamos la plantilla.
        for col in columns:
            if callable(col.get('template', None)):
                col['template'] = col['template']()

        self.set_arg('columns', columns)


    def _make_widgetname(self, name, row):
        return '__LMW__%s__WIDGET__%s__ROW__%s__' % (self.get_html_id(), name, row)

    def _append_args_from_template(self, original, templates, row_num, row_data):
        args = original.copy()
        for key, val in templates.items():
            args[key] = val(widget = self, row_num = row_num, row_data = row_data)
        return args

    def calljs_getitems(self):
        pattern = []
        getwidget = self.get_form().get_widget
        for column in self.get_arg('columns'):
            if column.has_key('widget'):
                pattern.append({
                    'name': column['widget']['name'], 
                    'id': getwidget(self._make_widgetname(column['widget']['name'], '%N')).get_html_id()
                })

        import json
        return 'mcw_lmw_getitems(%s, %s, %s)' % tuple(map(json.write, 
            [self.get_html_id(), self._get_counter_name(), pattern ]))


    def _get_counter_name(self):
        return self._make_var_name('row_counter')

    def _get_reg_items_id(self):
        return self._make_var_name('items_id')

    def render(self):
        return (ListMultiCol.render(self) + 
                '<input name="%s" value="" type="hidden" />' % self._get_reg_items_id())


