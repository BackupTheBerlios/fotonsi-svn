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
			Lee una línea y extrae los comentarios
		"""

		lin = self.f.readline()#.replace ("\n", "")
		if (len(lin) == 0):
			return -1

		lin = lin.replace ("\n", "").replace ("\r", "")

		# Si hay un comentario por ahí...
		if (lin.find("#") >= 0):
			
			# Caso de que esté al principio de la línea, seguimos leyendo hasta encontrar una línea normal
			if (lin[0] == "#"):
				while ((len(lin)>0) and (lin[0] == "#")):
					lin = self.f.readline()
			# En caso contrario, eliminamos la parte del comentario
			else:
				lin = lin.split("#")[0].strip()
		return lin

	def parse (self):
		lin = "" # Línea actual
		lin_ant = "" # Línea anterior a la actual
		cont = 0 # Contador de los ficheros individuales de pruebas
		f = None # Fichero donde vamos a grabar las pruebas individuales
		contenido = False # Bandera que controla si se guarda lo que se está leyendo

		lin = self.readline() # Lee una línea
		
		# La primera línea puede contener la variable URL
		if (lin.find("URL") >= 0):
			# Extraemos la url y leemos otra línea
			URL = lin.split("=")[1]
			existe_URL = True
			lin = self.readline()
	
		# Carga el título
		maintitle = lin.replace ("\n", "")

		# Lee una línea en blanco y continúa... (el bucle es por si encuentra comentarios por medio)
		lin = self.readline()
		lin = self.readline()

		# Lista de los títulos
		titles = list()
	
		# Recorre todo el fichero
		while lin <> -1:
			# Coge el título cuando llega a --------- y cambia de estado
			if (len(lin)>0) and (lin[0] == "-"):
				contenido = True
				title = lin_ant

				# Salta la línea de rayas -> ----------
				lin = self.readline() #self.f.readline()
				cont = cont + 1
			
				# Formatea el nombre del fichero (prefijo + nº correlativo)
				nfic = "%s%d.html" % (self.filePrefix, cont)

				# Guarda el título de la prueba actual en la lista de títulos
				titles.append ((lin_ant, nfic))
				
				# Abre el fichero html para guardar la próxima prueba individual
				f = open (nfic, "w")
				f.write (self._htmlHead)
				f.write ('<tr><td colspan="3">%s</td></tr>\n' % (title))

				# Saltamos a leer otra línea
				continue

			# Al recibir una línea en blanco, indica que se rompe el bloque
			elif (len(lin) == 0):
				contenido = False

				# Escribimos el pié de página, cerramos el fichero y seguimos pa'lante
				f.write (self._htmlBottom)
				f.close()

			# Cuando está dentro de una batería, va guardando los elementos
			elif (contenido == True):
				# Sustituye la variable $URL por el valor recogido (si se puso)
				if ((lin.find("$URL") > 0) and (existe_URL==True)):
					lin = lin.replace ("$URL", URL)

				cols = lin.split (" ")
				
				# Añade una columna adicional en HTML si sólo hay dos en el fichero (por ejemplo, el open sólo lleva dos columnas)
				if (len (cols) == 2):
					cols.append("")
				
				f.write ("<tr><td>%s</td><td>%s</td><td>%s</td></tr>\n" % (cols[0], cols[1], cols[2]))
			
			# Guardamos la línea actual como vieja y leemos otra nueva
			lin_ant = lin
			lin = self.readline() #self.f.readline()
	
		# Termina el parseo... guarda el pié de página y cierra el fichero
		f.write (self._htmlBottom)
		f.close()

		# Escribe el fichero principal
		f = open ("%s.html" % (self.filePrefix), "w")

		s = self._htmlHead

		# La primera línea será el título
		s = s + '<tr><td colspan="3">%s</td></tr>\n' % (maintitle)
	
		# Crea la columna del fichero principal a partir de los títulos (each[0]) y 
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
