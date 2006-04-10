# -*- coding: latin1 -*-

from MCWidgets.Escape import html_escape, uri_escape

def buildSelectFromList(options):

    r = '<select>'
    for opt in options:
        r += '<option>%s</option>' % html_escape(opt)
    return r + '</select>'

def buildScript(body):
    return ('<script languaje="JavaScript">\n' +
            body.replace('</script>', r'\x3c\x2f\x73\x63\x72\x69\x70\x74\x3e') + 
            '\n</script>')

def buildFormFields(fields):
    r = ''
    for name, values in fields.items():
        if not isinstance(values, list): values = [values]
        n = html_escape(name)
        for v in values:
            r += '<input type="hidden" name="%s" value="%s" />' % (n, html_escape(v))
    return r

def html_attribute(name, value):
    '''html_attribute(name, value) -> str

    Devuelve una cadena representando el atributo HTML de los
    valores indicados. Escapa caracteres que puedan ser conflictivos.

    Si value es None, devolverá sólo el nombre del atributo.'''

    if value is None:
        return html_escape(name)
    return '%s="%s"' % (html_escape(name), html_escape(value))

def html_dict_attrs(attrs):
    '''html_dict_attrs(attrs) -> str

    Crea una cadena con los atributos HTML indicados en el diccionario
    enviado'''

    return ' '.join([html_attribute(*at) for at in attrs.items()])

def html_dict_anchor_args(args):
    '''html_dict_anchor_args(args) -> str

    Crea una cadena para usar en los argumentos del anchor, a partir
    del diccionario pasado.
    '''

    new = []
    for key,value in args.items():
        if isinstance(value, list):
            for v in value: new.append('%s=%s' % (key, uri_escape(v)))
        else:
            new.append('%s=%s' % (key, uri_escape(value)))
    return html_escape('&'.join(new))
