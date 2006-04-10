# -*- coding: latin1 -*-

from MCWidgets.Widgets.BaseJS import BaseJS
from MCWidgets.Escape import html_escape
from MCWidgets.Widgets.HiddenData import HiddenData
from mx.DateTime import mxDateTime
from MCWidgets import Utils
import json

class ListMultiCol(BaseJS):

    def get_type(self):
        return 'MCWidgets.ListMultiCol'

    def initialize_type(self):
        self.get_form().add_prop('header', 
          '<script src="%s/listmulticol.js"></script>' % self.get_form()._get_url_static_files())

    def get_args_spec(self):
        req, opt = BaseJS.get_args_spec(self)
        return req + ['columns', 'data'], \
               opt + ['header_style', 'orderable', 'on_rows_change', 'order', 'rows_per_page']

    def get_variable_names(self):
        return [self.get_counter_name()]

    def get_names_order_data(self):
        return map(self._make_var_name, ('order_key', 'order_reverse'))

    def _get_order_data(self):
        order = self.get_arg('order')
        if not order:
            return None

        order = order.copy()

        # Comprobar si por parámetros se desea otra ordenación
        rawargs = self.get_form()._get_raw_form_values()
        args = self.get_names_order_data()

        order['key'] = rawargs.get(args[0], order['key'])
        order['reverse'] = rawargs.get(args[1], order['reverse'])

        return order

    def get_header_columns(self):

        from MCWidgets.Utils import html_dict_anchor_args

        cols = []
        order = self._get_order_data()
        arg_key, arg_reverse = self.get_names_order_data()

        for col in self.get_arg('columns'):
            if order and col.has_key('key'):
                args = order['extra_args'].copy()
                args[arg_key] = col['key']

                if order['key'] == col['key']:
                    args[arg_reverse] = 'yn'[order['reverse'] == 'y']
                    html = '<img border="0" alt="" src="/staticmcw/ord_%s.png" />' % (
                        ['up', 'down'][order['reverse'] == 'y'])
                else:
                    html = ''
                    args[arg_reverse] = 'n'

                cols.append('<a href="%s?%s">%s%s</a>' % (
                                order['url'],
                                html_dict_anchor_args(args),
                                html,
                                html_escape(col['name'])))
            elif not col.has_key('widget') or col['widget']['type'] is not HiddenData:
                cols.append(html_escape(col['name']))
            else:
                # es un HiddenData, pasamos de todo
                pass

        return cols

    def render(self):
        from cStringIO import StringIO

        out = StringIO()
        base_id = self.get_html_id()
        numrows = 0

        # Ver si queremos ejecutar una expesión cuando cambian las filas
        if self.get_arg('on_rows_change',  None):
            out.write('<script>var %s_js_rows_change = %s;</script>' % (
                self.get_html_id(),
                json.write(self.get_arg('on_rows_change'))))

        # Obtener las columnas. Si es un listado ordenable, añadimos la columa
        # con las flechas para subir y bajar filas
        columns = self.get_arg('columns')
        if self.get_arg('orderable'):
            columns = [{
                'name': '', 
                'template': '<span style="white-space: nowrap">'
                    '<input type="image" src="/staticmcw/up.png" onclick="try{mcw_lmc_moverow(this, -1);}catch(e){}; return false;" />'
                    '<input type="image" src="/staticmcw/down.png" onclick="try{mcw_lmc_moverow(this, 1);}catch(e){}; return false;" />'
                '</span>'
            }] + columns


        from MCWidgets.Utils import html_dict_attrs, html_dict_anchor_args
        out.write('<table %s>\n' % html_dict_attrs(self.get_calc_html_attrs()))

        rows_per_page = self.get_arg('rows_per_page', 0)
        formvalues = self.get_form()._get_raw_form_values()

        if rows_per_page > 0:
            order = self._get_order_data()
            args = order['extra_args']
            page = int(formvalues.get(self._make_var_page(), 0))
            args[self._make_var_page()] = str(page)

            # Coopiar la ordenación
            args = args.copy()
            arg_key, arg_reverse = self.get_names_order_data()
            args[arg_key] = order['key']
            args[arg_reverse] = order['reverse']

            out.write('<tr><td align="right" colspan="%d">' % len(columns))
            num_pags = len(self.get_arg('data')) / rows_per_page

            if page > 0:
                args[self._make_var_page()] = str(page - 1)
                out.write('<a href="%s?%s">Anterior</a> ' % (order['url'], html_dict_anchor_args(args)))

            if page < (num_pags-1):
                args[self._make_var_page()] = str(page + 1)
                out.write('<a href="%s?%s">Siguiente</a>' % (order['url'], html_dict_anchor_args(args)))

            args[self._make_var_page()] = 'xxNUMxPAGExMCWxLMCxx'
            out.write('&nbsp; &nbsp; <select onchange="location.href=&quot;%s?&quot; + %s.replace(&quot;xxNUMxPAGExMCWxLMCxx&quot;, this.value-1)">' % (
                    order['url'],
                    json.write(html_dict_anchor_args(args))))

            for n in range(num_pags):
                out.write('<option')
                if n == page: out.write(' selected')
                out.write('>%s</option>' % (n+1))

            out.write('</select></td></tr>')

        # Cabeceras
        out.write('<tr class="' + self.get_arg('header_style', '') + '">')
        if self.get_arg('orderable'): out.write('<th>&nbsp;</th>')
        for col in self.get_header_columns():
            out.write('<th>' + col + '</th>')
        out.write('</tr>\n')

        # Filas
        data = self.get_arg('data')
        out.write('<input type="hidden" name="%(c)s" id=%(c)s value="%(n)d" />' %  
            {'c': self.get_counter_name(), 'n': len(data)+1})

        # Vemos si tenemos que reordenar las filas
        order = self._get_order_data()
        if order:
            data = data[:]
            key = order['key']

            # TODO Si la columna tiene un translate, usar éste para ordenar 
            #      en lugar de directamente el valor

            data.sort(lambda a,b: cmp(a[key], b[key]))
            if order['reverse'] == 'y':
                data.reverse()

        # Miramos si queremos paginar
        if rows_per_page > 0:
            page = int(formvalues.get(self._make_var_page(), 0))
            data = data[rows_per_page*page:rows_per_page*(page+1)]
            out.write('<input type="hidden" name="%s" value="%s" />' % (
                    self._make_var_page(),
                    page))

        for row in data:
            numrows += 1
            tr_id = "%s_row_%d" % (base_id, numrows)
            out.write('<tr id="%s">' % tr_id)

            # Usaremos esta función para hacer las sustituciones necesarias
            # para las plantillas
            def _tpl_make(tpl):
                return (tpl.
                    replace('%DELROW%', html_escape(self.calljs_delrow(numrows))).
                    replace('%N', str(numrows)).
                    replace('%R', tr_id).
                    replace('%I', base_id))

            tds = []
            hid_cols = ""
            for col in columns:
                # TODO: Sacar a un método aparte el algoritmo para sacar el valor
                #       de cada fila, 
                # Comprobar si la columna se genera por una clausura o directamente
                # desde el valor de la lista

               
                if col.has_key('call'):
                    val = col['call'](row)
                elif col.has_key('call_template'):
                    val = _tpl_make(col['call_template'](row))
                elif not col.has_key('key'):
                    val = _tpl_make(col['template'])
                else:
                    val = row[col['key']]
                    if type(val) is mxDateTime.DateTimeType:
                        val = val.strftime('%d/%m/%Y')
                    elif type(val) is mxDateTime.DateTimeDeltaType:
                        val = val.strftime('%H:%M')
                    elif val is None:
                        val = '-'
                    else:
                        val = str(val)

                    if col.has_key('translate'):
                        val = col['translate'].get(val, val)

                    if col.get('html_escape', True):
                        val = html_escape(val)
                    if col.get('as_template', False):
                        val = _tpl_make(val)

                if col.has_key('widget') and col['widget']['type'] is HiddenData:
                    hid_cols += val
                else:
                    tds.append(val)

            out.write('<td>'+'</td><td>'.join(tds[:-1])+'</td>')
            out.write('<td>'+tds[-1]+hid_cols+'</td>')
            out.write('</tr>\n')

        # Procesamos las columnas para poner los hiddendata al final en lo que le pasamos al calljs_addrow
        hid_cols = ''
        tds = []
        for col in columns:
            val = col.get('template', '-empty-')
            if col.has_key('widget') and col['widget']['type'] is HiddenData:
                hid_cols += val
            else:
                tds.append(val)
            
        if hid_cols: tds[-1] += hid_cols

        
        # Template columns
        out.write(Utils.buildScript('var %s = %s ;' % (
                self.varjs_columns(),
                json.write(tds))))

        return out.getvalue() + '</table>\n'

    def render_button_add(self, label = 'Add'):
        return '<input type="button" value="%s" onclick="%s" />' % (
                label, 
                html_escape(self.calljs_addrow()))

    def render_filter(self):
        return '<input size="40" onkeypress="mcw_lmc_filter_keypress(this, %s)" />' % \
                html_escape(json.write(self.get_html_id()))

    def get_counter_name(self):
        return self._make_var_name('counter')

    def calljs_addrow(self):
        return 'mcw_lmc_addrow("%s", %s, "%s")' % (
            self.get_html_id(),
            self.varjs_columns(),
            self.get_counter_name()
        )

    def calljs_delrow(self, num):
        return 'mcw_lmc_delrow("%s_row_%s")' % (self.get_html_id(), num)

    ADDROW = property(lambda self: html_escape(self.calljs_addrow()), None, None)

    def varjs_columns(self):
        return self._make_var_name('js_columns')

    def _make_var_page(self):
        return self._make_var_name('page')
