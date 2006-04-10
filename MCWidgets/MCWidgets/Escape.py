# -*- coding: latin1 -*-

''' *Escapadores para MCWidgets

'''

class Escape:

    def __init__(self, replaces):
        self._replaces = replaces

    def __call__ (self, source):
        if isinstance(source, str):
            # Búsqueda de las cadenas a cambiar. 
            # TODO ¿Vale la pena optimizar el algoritmo?, pasarlo a C o pyrex
            result = ''
            offset = 0
            while offset < len(source):
                for from_, to in self._replaces:
                    if source.startswith(from_, offset):
                        offset += len(from_)
                        result += to
                        break
                else:
                    # Se recorrió toda la lista de remplazos pero
                    # no se encontró coincidencia. Se copia el caracter
                    # tal cual
                    result += source[offset]
                    offset += 1
            return result

        elif isinstance(source, Escape):
            return EscapeChain([source, self])

        elif isinstance(source, EscapeChain):
            return EscapeChain(source._list + [self])

        raise TypeError, 'Argument must be a string or a escape object'


class EscapeChain:

    def __init__(self, initial_list = []):
        import copy
        self._list = copy.copy(initial_list)

    def __call__(self, source):
        for esc in self._list:
            source = esc(source)
        return source



# Escapa una cadena para usarla como contenido en HTML
html_escape = Escape(
         [('&', '&amp;'), ('>', '&gt;'), ('<', '&lt;'), ('"', '&quot;'), ("'", '&#39;')] +
         [(chr(n), '&#%d;' % n) for n in range(32)])

# Escapa para meter el texto como cadena en JS
__alphanum = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
__js_valid_chars = __alphanum + ' =/().;,¡!¿?'

js_str_escape = Escape([ (chr(C), '\\x%02X' % C) 
                         for C in range(256) if chr(C) not in __js_valid_chars])

uri_escape = Escape([ (chr(C), '%%%02X' % C) 
                       for C in range(256) if chr(C) not in __alphanum])


del __js_valid_chars, __alphanum

