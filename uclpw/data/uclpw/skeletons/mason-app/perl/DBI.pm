package %(modulo_perl)::DBI;
use base 'Class::DBI';

use Class::DBI::AbstractSearch;
use Class::DBI::Plugin::RetrieveAll;
use Class::DBI::Pager;

use Config::Tiny;

my $fich_conf = "/etc/foton/%(proyecto).ini";
my $configuracion = Config::Tiny->new();
$configuracion = Config::Tiny->read($fich_conf);

our ($datos_con, $usuario_bd, $clave_bd) =
    ($configuracion->{base_datos}->{nombre},
     $configuracion->{base_datos}->{usuario},
     $configuracion->{base_datos}->{clave});

%(modulo_perl)::DBI->set_db('Main', $datos_con, $usuario_bd, $clave_bd, {AutoCommit=>1});

1;
