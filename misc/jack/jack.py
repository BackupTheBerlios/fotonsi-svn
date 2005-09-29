#!/usr/bin/env python
import sys

class jack:
	_htmlHead = "<html>\n<body>\n<table>\n"
	_htmlBottom = "</table>\n</body>\n</html>"

	def __init__ (self, fic, prefix):
		self.f = open (fic)
		self.filePrefix = prefix

	def readline (self):
		"""
			Lee una l�nea y extrae los comentarios
		"""

		lin = self.f.readline()#.replace ("\n", "")
		if (len(lin) == 0):
			return -1

		lin = lin.replace ("\n", "").replace ("\r", "")

		# Si hay un comentario por ah�...
		if (lin.find("#") >= 0):
			
			# Caso de que est� al principio de la l�nea, seguimos leyendo hasta encontrar una l�nea normal
			if (lin[0] == "#"):
				while ((len(lin)>0) and (lin[0] == "#")):
					lin = self.f.readline()
			# En caso contrario, eliminamos la parte del comentario
			else:
				lin = lin.split("#")[0].strip()
		return lin

	def parse (self):
		lin = "" # L�nea actual
		lin_ant = "" # L�nea anterior a la actual
		cont = 0 # Contador de los ficheros individuales de pruebas
		f = None # Fichero donde vamos a grabar las pruebas individuales
		contenido = False # Bandera que controla si se guarda lo que se est� leyendo

		lin = self.readline() # Lee una l�nea
		
		# La primera l�nea puede contener la variable URL
		if (lin.find("URL") >= 0):
			# Extraemos la url y leemos otra l�nea
			URL = lin.split("=")[1]
			existe_URL = True
			lin = self.readline()
	
		# Carga el t�tulo
		maintitle = lin.replace ("\n", "")

		# Lee una l�nea en blanco y contin�a... (el bucle es por si encuentra comentarios por medio)
		lin = self.readline()
		lin = self.readline()

		# Lista de los t�tulos
		titles = list()
	
		# Recorre todo el fichero
		while lin <> -1:
			# Coge el t�tulo cuando llega a --------- y cambia de estado
			if (len(lin)>0) and (lin[0] == "-"):
				contenido = True
				title = lin_ant

				# Salta la l�nea de rayas -> ----------
				lin = self.readline() #self.f.readline()
				cont = cont + 1
			
				# Formatea el nombre del fichero (prefijo + n� correlativo)
				nfic = "%s%d.html" % (self.filePrefix, cont)

				# Guarda el t�tulo de la prueba actual en la lista de t�tulos
				titles.append ((lin_ant, nfic))
				
				# Abre el fichero html para guardar la pr�xima prueba individual
				f = open (nfic, "w")
				f.write (self._htmlHead)
				f.write ('<tr><td colspan="3">%s</td></tr>\n' % (title))

				# Saltamos a leer otra l�nea
				continue

			# Al recibir una l�nea en blanco, indica que se rompe el bloque
			elif (len(lin) == 0):
				contenido = False

				# Escribimos el pi� de p�gina, cerramos el fichero y seguimos pa'lante
				f.write (self._htmlBottom)
				f.close()

			# Cuando est� dentro de una bater�a, va guardando los elementos
			elif (contenido == True):
				# Sustituye la variable $URL por el valor recogido (si se puso)
				if ((lin.find("$URL") > 0) and (existe_URL==True)):
					lin = lin.replace ("$URL", URL)

				cols = lin.split (" ")
				
				# A�ade una columna adicional en HTML si s�lo hay dos en el fichero (por ejemplo, el open s�lo lleva dos columnas)
				if (len (cols) == 2):
					cols.append("")
				
				f.write ("<tr><td>%s</td><td>%s</td><td>%s</td></tr>\n" % (cols[0], cols[1], cols[2]))
			
			# Guardamos la l�nea actual como vieja y leemos otra nueva
			lin_ant = lin
			lin = self.readline() #self.f.readline()
	
		# Termina el parseo... guarda el pi� de p�gina y cierra el fichero
		f.write (self._htmlBottom)
		f.close()

		# Escribe el fichero principal
		f = open ("%s.html" % (self.filePrefix), "w")

		s = self._htmlHead

		# La primera l�nea ser� el t�tulo
		s = s + '<tr><td colspan="3">%s</td></tr>\n' % (maintitle)
	
		# Crea la columna del fichero principal a partir de los t�tulos (each[0]) y 
		# el fichero asociado (each[0])
		for each in titles:
			s = s + '<tr><td><a href="%s">%s</a></td></tr>\n' % (each[1], each[0])

		s = s + self._htmlBottom

		f.write (s)
		f.close()

# Comprueba si los argumentos son correctos
if (len(sys.argv) <> 3):
	print "Error\n\njack.py fichero_formato_intermedio prefijo_salida_html"
	sys.exit(-1)

ficin = sys.argv[1] # Fichero con el formato intermedio 
fichtml = sys.argv[2] # Prefijo para los ficheros html

bat = jack (ficin, fichtml)
bat.parse()
