all: rdoc

rdoc:
	rdoc README lib/

test:
	# Variable de entorno en vez de opción, por si se ejecuta el fosc
	# desde dentro de alguna de las pruebas
	RUBYLIB=lib ruby -w test/ts_remix_widgets.rb

.PHONY: test rdoc
