use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'		=> '%{modulo_perl}',
    'VERSION_FROM'	=> '%{modulo_perl}.pm', # finds $VERSION
    'PREREQ_PM'		=> {
                              'Config::Tiny' => 1,
                           },
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => '%{modulo_perl}.pm',
       AUTHOR     => 'Fotón Sistemas Inteligentes <info@foton.es>') : ()),
);
