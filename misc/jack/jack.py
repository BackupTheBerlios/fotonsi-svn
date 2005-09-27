#!/usr/bin/env python
import sys

class jack:
	_htmlHead = "<html>\n<body>\n<table>\n"
	_htmlBottom = "</table>\n</body>\n</html>"

	def __init__ (self, fic, prefix):
		self.f = open (fic)
		self.filePrefix = prefix

	def parse (self):
		lin = self.f.readline()
		lin_ant = ""
		cont = 0
		f = None

		contenido = False

		# Carga el título
		maintitle = lin.replace ("\n", "")

		# Lee una línea en blanco y continúa...
		lin = self.f.readline()
		lin = self.f.readline()

		titles = list()

		# Bandera para comprobar si pasamos a leer otra línea
		pasar = False
		# Recorre todo el fichero
		while lin <> "":
			# Si hay un comentario por ahí...
			if (lin.find("#") >= 0):
				
				# Caso de que esté al principio de la línea, pasamos de largo
				if (lin[0] == "#"):
					pasar = True
				# En caso contrario, eliminamos la parte del comentario
				else:
					lin = lin.split("#")[0].strip()
		
			# En caso de una línea en blanco, pasamos de largo
			#elif (len(lin.strip()) == 0):
			#	pasar = True

			# Si hay que pasar de la línea se pasa, pero saltar para nada como que no.... leemos otra y rebotamos a otra vuelta del bucle
			if (pasar == True):
				lin = self.f.readline()
				pasar = False
				continue

			# En caso de encon
			lin = lin.replace("\n", "")
			
			# Coge el título cuando llega a --------- y cambia de estado
			if (len(lin)>0) and (lin[0] == "-"):
				contenido = True
				title = lin_ant

				# Salta la línea de rayas -> ----------
				lin = self.f.readline()
				cont = cont + 1
			
				# Formatea el nombre del fichero (prefijo + nº correlativo)
				nfic = "%s%d.html" % (self.filePrefix, cont)
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
				f.write (self._htmlBottom)
				f.close()

			# Cuando está dentro de una batería, va guardando los elementos
			if (contenido == True):
				cols = lin.split (" ")
				
				if (len (cols) == 2):
					cols.append("")
				
				f.write ("<tr><td>%s</td><td>%s</td><td>%s</td></tr>\n" % (cols[0], cols[1], cols[2]))
				
			lin_ant = lin
			lin = self.f.readline()
			
		f.write (self._htmlBottom)
		f.close()
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
	print "Error\n\nbat.py fichero_formato_intermedio prefijo_salida_html"
	sys.exit(-1)

ficin = sys.argv[1] # Fichero con el formato intermedio 
fichtml = sys.argv[2] # Prefijo para los ficheros html

bat = jack (ficin, fichtml)
bat.parse()
