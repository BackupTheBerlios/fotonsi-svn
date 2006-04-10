# -*- coding: latin1 -*-

from MCWidgets.Widgets.BaseJS import BaseJS
from MCWidgets.Escape import html_escape

class MultiValues(BaseJS):

    def get_type(self):
        return 'MCWidgets.MultiValues'

    def get_value(self):
        f = BaseJS.get_value(self)
        if f is None:
            f = self.get_arg('initial_selection')
        if not isinstance(f, list):
            f = [f]
        return f

    def get_args_spec(self):
        req, opt = BaseJS.get_args_spec(self)
        return [
            req + ['columns', 'initial_selection', 'key', 'source'],
            opt + ['label_button', 'table_class']
        ]

    def get_diffs(self):
        added = []
        removed = []
        old = []

        initial = self.get_arg('initial_selection')
        sent = BaseJS.get_value(self)

        if sent is None:
            # No se ha recibido ningún valor. Entendemos que se 
            # borraron todos
            return {'added': [], 'old': [], 'removed': initial}

        if not isinstance(sent, list):
            # Se ha recibido un solo valor
            sent = [sent]

        for i in initial:
            if i not in sent:
                removed.append(i)
            else:
                old.append(i)

        for i in sent:
            if i not in initial:
                added.append(i)

        return {'added': added, 'old': old, 'removed': removed}

    def initialize_type(self):
        form = self.get_form()
        form._add_js_file('multivalues.js')
        form._add_js_file('util.js')
        form._add_js_file('md5.js')
        form._add_js_file('prototype-1.2.0.js')

    def initialize_widget(self):

        source = self.get_arg('source')
        cols = self.get_arg('columns')
        key = self.get_arg('key')
        obj = {}

        for item in source:
            obj[item[key]] = [item[x['key']] for x in cols]

        import json
        self.get_form().add_prop('header',
            '<script>\n var %s = %s; \n</script>' % (
                self.varjs_columns(), 
                json.write(obj)))

    def render_input(self):
        return'<input onkeypress="return mcw_mv_keydown(this, event, function(){%s})" id="%s" value="" />' % (
            (html_escape(self.calljs_additem()), self._get_input_name()))

    def render_table(self):
        import md5

        key = self.get_arg('key')
        cols = self.get_arg('columns')
        source = dict([(s[key], s) for s in self.get_arg('source')])

        table_id = self._get_table_name()
        s = '<table class="%s" id="%s">\n<tr>' % (self.get_arg('table_class', ''), table_id)
        for c in cols:
            s += '<th>%s</th>' % html_escape(c['name'])
        s += '<th> <!-- remove button --> </th> </tr>\n'

        for item in self.get_value():
            row_id = table_id + '_row_' + md5.md5(str(item)).hexdigest()
            s += '<tr id="%s">' % row_id

            try:
                item = source[item]
                rowkey = item[key]
                for c in cols:
                    s += '<td>%s</td>' % html_escape(str(item[c['key']]))
            except KeyError, (e,):
                rowkey = str(item)
                s += "<td>%s <!-- the item, I did not convert it: Key %s --></td>" % (item, html_escape(str(e)))

            s += ('<td><input type="hidden" name="%s" value="%s" /> ' +
                  '<input type="button" value="-" ' +
                  '  onclick="mcw_mv_delitem(&quot;%s&quot;)" />' +
                  '</td></tr>\n') % (
                self.get_html_name(), html_escape(str(rowkey)), row_id)

        return s + '</table>\n'

    def render_button(self):
        return '<input type="button" value="%s" onclick="%s" />' % (
            self.get_arg('label_button', 'Add'),
            html_escape(self.calljs_additem()))

    def render(self):
        return self.render_input() + self.render_button() + self.render_table()

    def _get_table_name(self):
        return self._make_var_name('table')

    def _get_input_name(self):
        return self._make_var_name('inputvalue')

    def calljs_value_to_add(self):
        return 'document.getElementById("%s").value' % html_escape(self._get_input_name())

    def calljs_additem(self):
        return 'mcw_mv_additem("%s", %s, %s, "%s")' % (
            self._get_table_name(),
            self.calljs_value_to_add(),
            self.varjs_columns(),
            self.get_html_name())

    def varjs_columns(self):
        return self._make_var_name('columns_data')

