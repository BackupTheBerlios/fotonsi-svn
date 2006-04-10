# -*- coding: latin1 -*-

from MCWidgets.Widget import Widget
from MCWidgets.Form import WidgetWithoutNotification

js_attributes = '''
    onfocus onblur onselect onchange onclick ondblclick onmousedown onmouseup onmouseover
    onmousemove onmouseout onkeypress onkeydown onkeyup
'''.split()

class BaseJS(Widget):

    def get_calc_html_attrs(self):
        calcdict = Widget.get_calc_html_attrs(self)

        for at in js_attributes:
            a = self.get_arg(at, None)
            if a is not None: 
                calcdict[at] = a

        return calcdict

    def request_notification(self, event, calljs):
        ev = 'on' + event.lower()
        if ev not in js_attributes:
            raise WidgetWithoutNotification, 'Invalid notification "%s" for "%s"' % (ev, self.get_type())

        self.set_arg(ev, self.get_arg(ev, '') + calljs + ';')

    def get_args_spec(self):
        req, opt = Widget.get_args_spec(self)
        return req, (opt + js_attributes)

    def calljs_getvalue(self):
        return 'document.getElementById("%s").value' % self.get_html_id()

