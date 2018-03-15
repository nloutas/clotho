package Clotho;

use strict;
use warnings;
use Apache::RequestRec ();
use Apache::RequestIO ();
use Apache::Const -compile => qw(OK);

use lib "/var/www/html/pythia/lib";
use Clotho::Init;
#use Module::Reload;
$::CLOTHO_HOME = "/export/home/nloutas/public_html/clotho";
$::error_log = "$::CLOTHO_HOME/logs/error.log";

sub handler {
   my $r = shift;
   #Module::Reload->check();
#::syslog ('error', Dumper(\%ENV)); use Data::Dumper;

   $r->content_type('text/html; charset=UTF-8');
   &Clotho::Init::init();
   print $::content;
   &Clotho::Init::end();

   return Apache::OK;
}

### Clean up environment
$ENV{'PATH'} = '/bin:/usr/bin';
$ENV{'SHELL'} = '/bin/sh' if defined ($ENV{'SHELL'});
$ENV{'IFS'} = '' if defined ($ENV{'IFS'});
$ENV{'CDPATH'} = '';

1;
__END__
