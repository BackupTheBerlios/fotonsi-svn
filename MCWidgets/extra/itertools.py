# Usar s�lo cuando se est� con python2.2 o anteriores.
# En el 2.3 ya est� el m�dulo completo

class count:
    def __init__(self):
        self.n = 0
    def next(self):
        self.n += 1
        return self.n - 1
