
from Foton.WebWare import FotonPage, WebError

class %{APPLICATION_ID}Page(FotonPage):

    def write_page(self, content):

        import %{APPLICATION_ID}.plantillas.page
        page = %{APPLICATION_ID}.plantillas.page.page()

        page.header = self.props['header']

        resp = self.response()
        resp.write(page.start())
        resp.write(content)
        resp.write(page.end())

    def get_config_file(self):
        return open('/etc/foton/%{APPLICATION_ID}.ini')

    def get_error_template(self):
        from %{APPLICATION_ID}.plantillas.informe_error import informe_error
        return informe_error()

