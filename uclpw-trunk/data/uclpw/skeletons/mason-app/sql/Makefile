FICHEROS_SQL = $(shell for i in *.sql; do echo sellos/$$i.salida; done)
todo: $(FICHEROS_SQL)

sellos/%.salida: %
	psql -U %{DB_USER} %{DB_NAME} -f $< >$@
