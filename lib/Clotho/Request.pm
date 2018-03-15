package Clotho::Request;

use strict;
use Clotho::Config;
use Clotho::User;
use Clotho::Profile;
use Clotho::Search;
use Clotho::Translations;
use CGI qw(:all);
use Data::Dumper;

sub new {
    my $pkg  = shift;

    my $obj  = { @_, 'static_vars' => Clotho::Config->static_vars(), 
                     'admin_email' => $Clotho::Config::ADMIN_EMAIL,
               };
    foreach my $p (param()){
       $obj->{$p} = param($p);
    }
    $obj->{'time'} ||= localtime();
    $obj->{'view'} ||= 'public'; #default view
    bless $obj, $pkg;
    $obj->_init();
#::syslog('error', 'Request params '. Dumper($obj));
    return $obj;
}

sub view {
    my $self = shift;
    @_ ? $self->{'view'} = shift : return $self->{'view'};
}

sub language {
    my $self = shift;
    @_ ? $self->{'lang'} = shift : return $self->{'lang'};
}

sub template {
    my $self = shift;
    @_ ? $self->{'template'} = shift : return $self->{'template'};
}

sub templateid {
    my $self = shift;

    return ($self->{'template'} =~ /^\d*$/ ? $self->{'template'} : $self->get_templateid_by_simplename($self->{'template'}) );
}

sub path {
    my $self = shift;
    @_ ? $self->{'path'} = shift : return $self->{'path'};
}

sub uri {
    my $self = shift;
    @_ ? $self->{'uri'} = shift : return $self->{'uri'};
}

sub referer {
    my $self = shift;
    @_ ? $self->{'referer'} = shift : return $self->{'referer'};
}

sub time {
    my $self = shift;
    @_ ? $self->{'time'} = shift : return $self->{'time'};
}

sub userid {
    my $self = shift;
    @_ ? $self->{'userid'} = shift : return $self->{'userid'};
}

sub cookie {
    my $self = shift;
    @_ ? $self->{'cookie'} = shift : return $self->{'cookie'};
}

# Used in Search; the No of page results
sub pageno {
    my $self = shift;
    return ($self->{'pageno'} || 1); 
}

sub validation_errors {
    my $self = shift;
    @_ ? $self->{'validation_errors'} .= shift : return $self->{'validation_errors'};
}

sub http_host {
    my $self = shift;
    return $::ENV{'HTTP_HOST'}; 
}

sub site {
    my $self = shift;
    @_ ? $self->{'site'} .= shift : return $self->{'site'};
}
############################################################################
# CORE METHODS
############################################################################

sub _init {
    my $self = shift;

    # LANGUAGE handling
    if ($self->language){
    #set the LANGUAGE in the cookie
       $self->cookie( $::query->cookie(
                               -name    => 'lang',
                               -value   => $self->language,
                              #-domain  => $ENV{'SERVER_NAME'},
                               -path    => '/')
                    );
    }
    else {
    #read the LANGUAGE from the cookie OR use the default LANGUAGE
       $self->language($::query->cookie('lang') || $Clotho::Config::DEFAULT_LANG); 
    }

    #read the login Userid from the cookie OR use the default 1 for 'visitor'
    $self->userid($::query->cookie('clotho_login') || 1); 

    # STATUS cache
    $self->{'status'} ||= $self->get_status_details();
    # SITE 
    $self->{'site'} ||= '/'.(split '/', $self->path)[1];
}

sub sitemap {
   my $self = shift;
   my $startPagePath = shift || $self->{'site'} || '/';
   my $depth = shift || 3;

   unless ($self->{"sitemap_$startPagePath"}){
      my $startPage = new Clotho::Page( path => $startPagePath, depth=>$depth, rootNode => 1);
      push @{$self->{"sitemap_$startPagePath"}}, $startPage;
      push @{$self->{"sitemap_$startPagePath"}}, 
           grep {!(Clotho::Config->hidden_page($_->path))} @{$startPage->children($depth-1)};
   }

   return @{$self->{"sitemap_$startPagePath"}};
}

sub private_view {
   my $self = shift;
   return ($self->view ne 'public' && !$self->user->public);
}

sub user {
   my $self = shift;
   $self->{'user'} ||= new Clotho::User(id => $self->{'userid'}, username => $self->{'username'}); 
   return $self->{'user'};
}
sub editUser {
   my $self = shift;
   return unless $self->{'editUserid'};
   $self->{'editUser'} ||= new Clotho::User(id => $self->{'editUserid'});
   return $self->{'editUser'};
}

sub editTemplate {
   my $self = shift;
   return unless $self->{'editTemplateid'};
   $self->{'editTemplate'} ||= new Clotho::Template(id => $self->{'editTemplateid'});
   return $self->{'editTemplate'};
}

sub profile {
   my $self = shift;
   return unless $self->{'profileid'};
   $self->{'profile'} ||= new Clotho::Profile(id => $self->{'profileid'}); 
   return $self->{'profile'};
}

sub search {
   my $self = shift;
   $self->{'search'} ||= new Clotho::Search(id => $self->{'searchid'}, keyword => $self->{'keyword'}, root => $self->{'searchRoot'}); 
   return $self->{'search'};
}

sub element {
   my $self = shift;
   $self->{'element'} ||= new Clotho::Element(id => $self->{'elementid'}, 
                                               type => $self->{'element_type'}); 
   return $self->{'element'};
}

sub today {
   my $self = shift;
   return $self->{'date'} if ($self->{'date'}); #cache
   my ($d, $m, $y) = (localtime)[3,4,5];
   $self->{'date'} = join "/", ($d, (++$m < 10 ? "0$m" : $m), ($y+1900));
   return $self->{'date'};
}
########################################################################################
# DB methods
########################################################################################
sub get_templateid_by_simplename {
   my $self = shift;
   my $template_simplename  = shift;
   $::dbquery{'get_templateid_by_simplename'} ||= $::dbh->prepare(qq{SELECT id FROM template WHERE simplename = ?});
   $::dbquery{'get_templateid_by_simplename'}->execute($template_simplename);
   my $templateid;
   $templateid = $::dbquery{'get_templateid_by_simplename'}->fetchrow
             unless ($::dbquery{'get_templateid_by_simplename'}->err);
   return $templateid;
}
sub get_status_details {
   my $self = shift;
   $::dbquery{'get_status_details'} ||= $::dbh->prepare(qq{SELECT * FROM status});
   $::dbquery{'get_status_details'}->execute();

   my $status;
   $status = $::dbquery{'get_status_details'}->fetchall_arrayref( {} )
            unless ($::dbquery{'get_status_details'}->err);

   return ($status || []);
}

sub profiles {
   my $self = shift;
   unless ($self->{'profiles'}){
      $::dbquery{'get_profile_details'} ||= $::dbh->prepare(qq{SELECT * FROM profile});
      $::dbquery{'get_profile_details'}->execute();

      $self->{'profiles'} = $::dbquery{'get_profile_details'}->fetchall_arrayref( {} )
            unless ($::dbquery{'get_profile_details'}->err);
   }

   return ($self->{'profiles'} || []);
}

sub users {
   my $self = shift;
   unless ($self->{'users'}){
      $::dbquery{'get_users'} ||= $::dbh->prepare(qq{SELECT id,
         username, fullname, email, profileid, disabled, 
	 DATE_FORMAT(updatedate, '%d/%m/%Y') as updatedate FROM usr});
      $::dbquery{'get_users'}->execute();

      $self->{'users'} = $::dbquery{'get_users'}->fetchall_arrayref( {} )
            unless ($::dbquery{'get_users'}->err);
   }

   return ($self->{'users'} || []);
}

sub templates {
   my $self = shift;
   unless ($self->{'templates'}){
      my $condition = $self->user->admin ? '' : 'WHERE hidden = 0';
      $::dbquery{'get_templates'} ||= $::dbh->prepare(qq{SELECT id, name,
         simplename, path, hidden, DATE_FORMAT(updatedate, '%d/%m/%Y') as updatedate
	 FROM template $condition});
      $::dbquery{'get_templates'}->execute();

      $self->{'templates'} = $::dbquery{'get_templates'}->fetchall_arrayref( {} )
            unless ($::dbquery{'get_templates'}->err);
   }

   return ($self->{'templates'} || []);
}

sub elements {
   my $self = shift;
   unless ($self->{'elements'}){
      $::dbquery{'get_elements'} ||= $::dbh->prepare(qq{SELECT id, name,
         type, templateid, DATE_FORMAT(updatedate, '%d/%m/%Y') as updatedate
	 FROM element });
      $::dbquery{'get_elements'}->execute();

      $self->{'elements'} = $::dbquery{'get_elements'}->fetchall_arrayref( {} )
            unless ($::dbquery{'get_elements'}->err);
   }

   return ($self->{'elements'} || []);
}

########################################################################################
# special methods
########################################################################################
sub translate {
   my $self = shift;
   my $msg  = shift;
   my $lang = lc $self->language; #lower case for language code
   return $msg if ($lang eq 'en');
   return Clotho::Translations::translate($msg,$lang);
}

sub escape {
   my $self = shift;
   my $msg  = shift || return;
   $msg =~ s/\\/\\\\/g;
   $msg =~ s/'/\\'/g;
   $msg =~ s/"/\\"/g;
   return $msg;
}

sub commitDB {
   my $self = shift;
   $::dbh->commit or ::syslog('error', 'Unable to commit into DB : '. $::dbh->errstr);
}

sub hint {
   my $self = shift;
   my $msg  = shift || return;
   my $alert = $self->escape($self->translate($msg));
   my $img  = '<img src="'.$self->{'static_vars'}{'imgpath'}.qq{/hint.gif" border="0" onClick="alert('$alert');" alt="hint"> \n};

   return $img;
}

1;
__END__

=item $object->view

returns the view of the request

=cut
