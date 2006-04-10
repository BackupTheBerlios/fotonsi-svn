# Usar sólo cuando se esté con python2.2 o anteriores.
# En el 2.3 ya está el módulo completo

class count:
    def __init__(self):
        self.n = 0
    def next(self):
        self.n += 1
        return self.n - 1
