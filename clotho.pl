#!/usr/bin/perl

# Copyright (c) 2004-06 Nikolaos Loutas <clotho@loutas.com>. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
# Clotho contains no adware, spyware, nagware or other unhealthy additives.

### Clean up environment
$ENV{'PATH'} = '/bin:/usr/bin';
$ENV{'SHELL'} = '/bin/sh' if defined ($ENV{'SHELL'});
$ENV{'IFS'} = '' if defined ($ENV{'IFS'});
$ENV{'CDPATH'} = '';

use strict;
use lib "/export/home/nloutas/public_html/clotho/lib"; 
$::CLOTHO_HOME = (-d "/export/home/nloutas/public_html/clotho") ? "/export/home/nloutas/public_html/clotho" : "/home/nloutas/public_html/clotho";
$::error_log = "$::CLOTHO_HOME/logs/error.log";
use Clotho::Init;

{
   &Clotho::Init::init();
   print $::header, $::content;
   &Clotho::Init::end();
}

#::syslog ('error', Dumper(\%ENV)); use Data::Dumper;
exit (1);

sub END () {
   # kill any pending processes
   if ($@) {
      ::syslog ('warning', 'killing undead handlers');
      kill (KILL => -$$);
   }
}

1;
__END__
