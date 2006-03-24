package %{modulo_perl};

use strict;

# $Id: Modulo.pm,v 1.1.1.1 2004/05/12 09:39:58 zoso Exp $

use vars qw(@EXPORT_OK);
require Exporter;
*import = \&Exporter::import;
@EXPORT_OK = qw();

=head1 NOMBRE

%{modulo_perl} - %{RESUMEN}

=head1 DESCRIPCIÓN

%{RESUMEN}

=head1 DERECHOS

Esta aplicación es libre. Puedes redistribuirla o modificarla bajo los mismos
términos que Perl.

 Derechos de autor 2004 Fotón Sistemas Inteligentes

=cut

our $VERSION = 0.01;

1;
