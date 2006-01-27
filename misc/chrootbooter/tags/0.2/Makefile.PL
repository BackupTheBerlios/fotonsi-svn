use ExtUtils::MakeMaker;

sub MY::postamble {
   return <<'INSTALL_INI';
install ::
	@if [ ! -r /etc/chrootbooter.ini ]; then \
                cp chrootbooter.ini-sample /etc/chrootbooter.ini; \
                echo "***************************"; \
                echo "Don't forget to edit /etc/chrootbooter.ini to suit your needs!"; \
                echo "***************************"; \
        fi
INSTALL_INI
}

WriteMakefile(
    'NAME'		=> 'chrootbooter',
    'VERSION_FROM'	=> 'script/chrootbooter.pl', # finds $VERSION
    'PREREQ_PM'		=> {
                              'Config::Tiny' => 1,
                           },
    'EXE_FILES'         => ['script/chrootbooter.pl'],
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'script/chrootbooter.pl',
       AUTHOR     => 'Fotón Sistemas Inteligentes <info@foton.es>') : ()),
);
