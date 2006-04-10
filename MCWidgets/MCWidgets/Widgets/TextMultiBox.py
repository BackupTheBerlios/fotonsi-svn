# -*- coding: latin1 -*-

from __future__ import generators

from MCWidgets.Widgets.TextBox import TextBox
from MCWidgets.Widgets.BaseJS import BaseJS 
import json

class TextMultiBox(TextBox):

    def get_type(self):
        return 'MCWidgets.TextMultiBox'

    def initialize_type(self):
        form = self.get_form()
        form._add_js_file('textmultibox.js')

    def get_value(self):
        var = self.get_form()._get_raw_form_values().get
        val = [var(box['name'], '') for box in self._get_boxes_args()]

        if not ''.join(val):
            # formulario inicial
            val = self.get_arg('initial_value', [''] * len(val))

        return val

    def get_args_spec(self):
        req, opt = TextBox.get_args_spec(self)
        return req + ['boxes'], opt

    def validate_widget(self):
        return TextBox.validate_widget(self)

    def get_validation_js_info(self):
        return TextBox.get_validation_js_info(self)

    def get_html_id(self):
        return self._make_var_name('id_box_0')

    def _get_boxes_args(self):
        import itertools
        count = itertools.count().next
        boxes = []

        for box in self.get_arg('boxes'):
            n = count()
            boxes.append({
                'id': self._make_var_name('id_box_%s' % n),
                'name': self._make_var_name('val_box_%s' % n),
            })

        ids = json.write([b['id'] for b in boxes])
        for (box, bdict) in zip(self.get_arg('boxes'), boxes):
            if box.has_key('max'):
                bdict['maxlength'] = bdict['size'] = str(box['max'])
                bdict['onkeypress'] = 'return tmb_keypress(this, %s);' % ids

        return boxes

    def render(self):
        return ' '.join(list(self.render_boxes()))

    def render_boxes(self):
        from MCWidgets import Utils
        attrs = self.get_calc_html_attrs()
        values = iter(self.get_value()).next
        for box in self._get_boxes_args():
            a = attrs.copy()
            a.update(box)
            a['value'] = values()

            yield '<input %s />' % Utils.html_dict_attrs(a)
