
from MCWidgets.Widget import Widget
from MCWidgets.Escape import js_str_escape

class ToolTips(Widget):

    def __init__(self, *a, **b):
        Widget.__init__(self, *a, **b)

        self.__form_widgets = []

    def get_type(self):
        return 'MCWidgets.ToolTips'

    def update_widgets_list(self, widgets):
        for widget in widgets.values():
            if ((widget is not self) and 
                (widget not in self.__form_widgets)):

                wid = widget.get_html_id()
                htmlhelp = widget.get_arg('htmlhelp', None)
                if htmlhelp is not None:
                    widget.request_notification('mouseover', 'mcw_tt_show_tooltop("%s", "%s")' % 
                            (wid, js_str_escape(htmlhelp)))
                    widget.request_notification('mouseout', 'mcw_tt_hide_tooltip("%s")' % wid)

                self.__form_widgets.append(widget)

    def initialize_type(self):
        self.get_form()._add_js_file('tooltip.js')

    def render(self):
        return '<!-- ToolTips widget -->'
