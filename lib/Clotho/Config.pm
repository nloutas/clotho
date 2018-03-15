package Clotho::Config;

$DEBUG = 1;
$DEFAULT_LANG = 'EN';
%DB_SETTINGS = ( 'database' => 'clothodb',
                 'username' => 'clotho',
                 'password' => 'mar1kak1',
                 'blobblock' => 8192,
               );

$ADMIN_EMAIL = 'clotho@loutas.com';

my %elements = (
	Article 	=> { },
	Image		=> { },
	Navigation 	=> { },
	RichText	=> { },
	Text		=> { },
	RSSitem		=> { },
	Frame		=> { },
	Search		=> { },
);

sub elements {
    return qw(Article Image Navigation RichText Text Search);
    sort keys %elements;
}
sub allowed_element {
    return $elements{$_[1]};
}

my %commands = (
   'sendmail'	=> '/usr/lib/sendmail -t'
);
sub command {
   return $commands{$_[1]};
}

my %hidden_pages = (
        '/admin/' => 1,
        '/error/' => 1,
        '/sitemap/' => 1,
        '/help/' => 1,
);

sub hidden_page {
   return $hidden_pages{$_[1]};
}

# static variables for template use
my %static_vars = (
   'clotho' => { 
        basepath=> '/static',
        jspath  => '/static/js',
        imgpath => '/static/img',
        csspath => '/static/css' },
  );

sub static_vars {
    return ($static_vars{$::ENV{'SERVER_NAME'}}  ||  $static_vars{'clotho'});
}

my %multimedia_types = (
	'PDF'         => 'PDF',
    	'Audio/Video' => 'MPEG',
    	'Zip'         => 'Zip',
   	'Software'    => 'Exe',
    	'Word'        => 'Word',
    	'Excel'       => 'Excel',
    	'PowerPoint'  => 'PowerPoint',
);

sub multimedia_types {
   return sort %multimedia_types;
}

%STATUSCODE = (
        100 => {userdef => 1, message => 'Continue'},
        101 => {userdef => 1, message => 'Switching protocols'},
        200 => {userdef => 1, message => 'OK'},
        201 => {userdef => 1, message => 'Created'},
        202 => {userdef => 1, message => 'Accepted'},
        203 => {userdef => 1, message => 'Non-authoritative information'},
        204 => {userdef => 1, message => 'No content'},
        205 => {userdef => 1, message => 'Reset content'},
        206 => {userdef => 1, message => 'Partial content'},
        300 => {userdef => 1, message => 'Multiple choices'},
        301 => {userdef => 0, message => 'Moved permanently'},
        302 => {userdef => 0, message => 'Moved temporarily'},
        303 => {userdef => 1, message => 'See other'},
        304 => {userdef => 2, message => 'Not modified'},
        305 => {userdef => 1, message => 'Use proxy'},
        400 => {userdef => 1, message => 'Bad request'},
        401 => {userdef => 1, message => 'Unauthorised'},
        402 => {userdef => 1, message => 'Payment required'},
        403 => {userdef => 1, message => 'Forbidden'},
        404 => {userdef => 1, message => 'Not found'},
        405 => {userdef => 1, message => 'Method not allowed'},
        406 => {userdef => 1, message => 'Not acceptable'},
        407 => {userdef => 1, message => 'Proxy authentication required'},
        408 => {userdef => 1, message => 'Request time-out'},
        409 => {userdef => 1, message => 'Conflict'},
        410 => {userdef => 1, message => 'Gone'},
        411 => {userdef => 1, message => 'Length required'},
        412 => {userdef => 0, message => 'Precondition failed'},
        413 => {userdef => 1, message => 'Request entity too large'},
        414 => {userdef => 1, message => 'Request URI too large'},
        415 => {userdef => 1, message => 'Unsupported media type'},
        500 => {userdef => 1, message => 'Server error'},
        501 => {userdef => 1, message => 'Not implemented'},
        502 => {userdef => 1, message => 'Bad gateway'},
        503 => {userdef => 1, message => 'Service unavailable'},
        504 => {userdef => 1, message => 'Gateway time-out'},
        505 => {userdef => 1, message => 'HTTP version not supported'}
        );
sub statuscode {
   return $STATUSCODE{$_[1]};
}

%FILETYPES = (
	'xml' 	=> 'text/xml',
	'htm' 	=> 'text/html',
	'html' 	=> 'text/html',
);
sub filetype {
   return $FILETYPES{$_[1]};
}

1;
__END__

=item Clotho::Config->elements

Returns an array containing the names of all the available elements in this installation.

=cut
