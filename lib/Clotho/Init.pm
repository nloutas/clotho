package Clotho::Init;
use strict;
# CPAN modules
use Template;
use DBI;
use CGI;
use FileHandle;
use Data::Dumper;

# Clotho modules
use Clotho::Config;
use Clotho::Page;
use Clotho::Request;

sub init {

    # initialise the Template Object
    $::tt ||= Template->new({ INCLUDE_PATH => "$::CLOTHO_HOME/templates:$::CLOTHO_HOME/lib", PLUGIN_BASE  => "Clotho::Plugin" });
    unless ($::tt) {
        &::syslog ('error', 'Unable to initialise Template! Error: '. $Template::ERROR);
        exit (1);
    }

    &_mysqlinit();
    # initialise the GCI Object
    $::query = CGI::new();
    # initialise the Clotho::Request Object
    my ($path, $query_string) = split '\?', $ENV{'REQUEST_URI'}, 2;
    $::request = new Clotho::Request('path' => $path, 
                                   'query' => $query_string, 
				   'uri' => $ENV{'REQUEST_URI'}, 
				   'referer' => $ENV{'HTTP_REFERER'});

    # initialise the Clotho::Page Object
    $::page = new Clotho::Page( 'path' => $::request->path || $ARGV[0] || '/' );
    my $elements = $::page->get_elements() unless ($::request->template || $::request->{'updateArea'});

    #process the page template
    $::content = $::page->template->process({elements => $elements, page => $::page, request => $::request});

    #prepare the HTML headers last, as the request cookie is set during template processing
    $::header = $::query->header(-cookie=>$::request->cookie, -charset=>'UTF-8', -type=>$::page->type);
}

sub end {
   &_mysqlend();
   &::syslog ('info', 'Clotho terminated');
}

sub _mysqlinit {
   return if $::dbh;
   my %DB_SETTINGS = %Clotho::Config::DB_SETTINGS;
   unless ($::dbh = DBI->connect ("dbi:mysql:$DB_SETTINGS{'database'}", $DB_SETTINGS{'username'}, $DB_SETTINGS{'password'},{RaiseError => 1, AutoCommit => 0, PrintError => 1, LongTruncOk => 1, LongReadLen => $DB_SETTINGS{'blobblock'}})) {
          &::syslog ('error', "error logging on to Mysql $DB_SETTINGS{'database'} as $DB_SETTINGS{'username'}: cannot connect ");
          exit (1);
   }
}

sub _mysqlend {
   # If connected to Database , commit and disconnect cleanly
   if (defined ($::dbh) && ($::dbh)) {
      &::syslog ('info', 'disconnecting from Database');
      $::dbh->commit;
      foreach (keys %::dbquery) { $::dbquery{$_}->finish; }
      $::dbh->disconnect;
   }
}

package main;
#declare main Vars
use vars qw (
	$CLOTHO_HOME
	$error_log 
        $dbh
        %dbquery
        $request
        $page
        $query
        $tt
        $static_vars
        %client
        $header
        $content
      );
 
sub syslog ($$@) {
    my ($level, $message, @args) = @_;

    my ($package, $filename, $line, undef) = caller (0);
    my (undef, undef, undef, $subroutine) = caller (1);

    open (ERRORLOG, ">> $::error_log") || die ("Can't open error log $::error_log: $!\n");
    open (STDERR, '>&ERRORLOG');
    ERRORLOG->autoflush (1);

    printf ERRORLOG ("$package %5d %5s: %s (%s:%d): %s\n", $$,$level,$subroutine,$filename,$line,$message) 
       if (($Clotho::Config::DEBUG &&  $level eq 'debug') || $level eq 'error');

    return;
}

1;
__END__
