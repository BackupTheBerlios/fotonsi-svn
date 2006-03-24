TMPLS=$(shell ls *.tmpl | sed 's/tmpl$$/py/')

all: $(TMPLS)

$(TMPLS): %.py: %.tmpl
	cheetah-compile --nobackup $<
