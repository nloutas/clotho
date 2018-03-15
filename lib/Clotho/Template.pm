package Clotho::Template;
use strict;
use Template;
use Data::Dumper;

sub new {
    my $pkg  = shift;
    my $obj  = { @_, '_cached' => 0 };
    bless $obj, $pkg ;
    $obj->get_template_details();

    return $obj;
}

###############################################################
# ACCESSOR METHODS
###############################################################

sub id {
    my $self = shift;
    @_ ? $self->{'id'} = shift : return $self->{'id'};
}

sub name {
    my $self = shift;
    @_ ? $self->{'name'} = shift : return $self->{'name'};
}

sub simplename {
    my $self = shift;
    @_ ? $self->{'simplename'} = shift : return $self->{'simplename'};
}

sub path {
    my $self = shift;
    @_ ? $self->{'path'} = shift : return $self->{'path'};
}

sub content {
    my $self = shift;
    @_ ? $self->{'content'} = shift : return $self->{'content'};
}

sub hidden {
    my $self = shift;
    @_ ? $self->{'hidden'} = shift : return $self->{'hidden'};
}

sub updatedate {
    my $self = shift;
    @_ ? $self->{'updatedate'} = shift : return $self->{'updatedate'};
}

############################################################################
# CORE METHODS
############################################################################

sub process {
    my $self = shift;
    my $data = shift;

    my $process_tmpl = $self->process_tmpl;
    my $out = '';
    unless ($::tt->process($process_tmpl, $data , \$out)) {
       ::syslog ('error', 'Unable to process Template: '.$self->name ." Error: ". $::tt->error() );
    }

    return $out;
}
 
sub process_tmpl {
    my $self = shift;
    # file path is preferred, otherwise use the WML content stored in the DB
    return ($self->path || \$self->content || 'blank.wml');
}

sub insert {
    my $self = shift;
    my $newTmpl = {};
    foreach ('name','simplename'){
       $::request->validation_errors("<div class='error_msg'>ERROR: $_ field is mandatory!</div>")
                unless ($::request->{"tmpl_$_"});
       $newTmpl->{$_} = $::request->{"tmpl_$_"};
    }

    foreach ('path','content','hidden'){
       $newTmpl->{$_} = $::request->{"tmpl_$_"};
    }

    return if ($::request->validation_errors);
    #commit to DB
    if ($self->_insert($newTmpl)){
       #JS redirect
       return '<script language="Javascript" type="text/javascript">self.location="?view=admin&template=adminTemplates"</script> ';
    }
    return 'Problems encountered in inserting new Template. Please check the logs!';
}

sub update {
    my $self = shift;
    my %updates = ();
    foreach ('name','simplename'){
       $::request->validation_errors("<div class='error_msg'>ERROR: $_ field is mandatory!</div>")
          unless ($::request->{"tmpl_$_"});
       $updates{$_} = $::request->{"tmpl_$_"};
    }

    foreach ('path','content','hidden'){
       $updates{$_} = $::request->{"tmpl_$_"};
    }

    return if ($::request->validation_errors);
    #commit to DB
    if ($self->_update(%updates)){
       #JS redirect
       return '<script language="Javascript" type="text/javascript">self.location="?view=admin&template=adminTemplates"</script>';
    }
    return 'Problems encountered in updating the Template details. Please check the logs!';
}

sub delete {
   my $self = shift;
   my $id = shift;
   my $result = $self->_delete($id);
   if ($result eq '0E0'){
      return "<div class=error_msg>Template with ID '$id' does not exist.</div>";
   }
   elsif ($result){
      return "<div class=success_msg>Template has been successfully deleted.</div>";
   }
   return "<div class=error_msg>Problems encountered in deleting the Template. Please check the logs!</div>";
}

############################################################################
# DB methods
############################################################################

sub get_template_details {
   my $self = shift;
   my $id = shift || $self->id || return;

   $::dbquery{'get_template_details'} ||= $::dbh->prepare(qq{SELECT id, name,
   simplename, path, content, hidden, DATE_FORMAT(updatedate, '%d/%m/%Y') as updatedate
   FROM template WHERE id = ? } );

   $::dbquery{'get_template_details'}->execute($id);

   my $results = {};
   $results = $::dbquery{'get_template_details'}->fetchrow_hashref
             unless ($::dbquery{'get_template_details'}->err);

   if ($results){
      %$self = (%$self, %{$results});
   }
   else {
      ::syslog ('error', "Template with id '".$self->id ."' is not present in the DB!" );
   }
}

sub _insert {
   my $self = shift;
   my $newTmpl = shift;

   $::dbquery{'insert_tmpl'} ||= $::dbh->prepare(qq{INSERT INTO template VALUES(NULL,?,?,?,?,?,now())});

   unless ($::dbquery{'insert_tmpl'}->execute($newTmpl->{'name'},$newTmpl->{'simplename'},$newTmpl->{'path'},$newTmpl->{'content'}, ($newTmpl->{'hidden'} || 0) )) {
      ::syslog('error', 'Unable to insert new template : '. $::dbh->errstr);
      $::dbh->rollback;
      return;
   }

   return 1;
}

sub _update {
   my $self = shift;
   my $id   = $self->id;
   my %val  = @_;
   return unless (%val);
   my $updates = '';
   foreach (keys %val){
      $updates .= ", $_ = '$val{$_}'";
   }

   my $result = $::dbh->do("UPDATE template set updatedate = now() $updates WHERE id = $id", undef);
   unless ($result){
      ::syslog('error', "Unable to update template '$id': $updates ". $::dbh->errstr);
      $::dbh->rollback;
      return;
   }
   return $result;
}

sub _delete {
   my $self = shift;
   my $id = shift;
   my $result;
   $result = $::dbh->do("DELETE FROM template WHERE id = ?", undef, $id)
      or ::syslog('error', "Unable to delete template '$id': ". $::dbh->errstr);

   return $result;
}

sub hide {
   my $self = shift;
   return $self->update('hidden' => 1);
}

1;
__END__

=head1 NAME

Clotho::Template - wrap a templating system

=head1 SYNOPSIS

 use Clotho::Template;
 print Clotho::Template->process(\%data);

=head1 DISCUSSION

=head2 Methods

=over

=item Clotho::Template->process

Process a template

=back
