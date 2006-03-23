use ExtUtils::MakeMaker;

sub MY::postamble {
   return <<'INSTALL_INI';
install ::
	make -C libchrb install
	@if [ ! -r /etc/chrootbooter.ini ]; then \
                cp chrootbooter.ini-sample /etc/chrootbooter.ini; \
                echo "***************************"; \
                echo "Don't forget to edit /etc/chrootbooter.ini to suit your needs!"; \
                echo "***************************"; \
        fi

clean ::
	make -C libchrb clean
INSTALL_INI
}

WriteMakefile(
    'NAME'		=> 'chrootbooter',
    'VERSION_FROM'	=> 'script/chrootbooter', # finds $VERSION
    'PREREQ_PM'		=> {
                              'Config::Tiny' => 1,
                              'IO::Interface' => 0.98,
                           },
    'EXE_FILES'         => ['script/chrootbooter'],
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'script/chrootbooter',
       AUTHOR     => 'Fotón Sistemas Inteligentes <info@foton.es>') : ()),
);
