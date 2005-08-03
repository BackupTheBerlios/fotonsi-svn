all: rdoc

rdoc:
	rdoc bin README lib/ data/fosc/plugins/

test:
	# Variable de entorno en vez de opción, por si se ejecuta el fosc
	# desde dentro de alguna de las pruebas
	RUBYLIB=lib:data/fosc ruby -w test/ts_fosc.rb

.PHONY: test rdoc
