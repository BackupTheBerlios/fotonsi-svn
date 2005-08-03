FICHEROS_SQL = $(shell for i in *.sql; do echo sellos/$$i.salida; done)
todo: $(FICHEROS_SQL)

sellos/%.salida: %
	psql -U %(usuario_bdd) %(base_datos) -f $< >$@
