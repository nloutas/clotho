package Clotho::Profile;
use strict;

use Data::Dumper;

sub new {
    my $pkg  = shift;
    my $obj  = { @_, '_cached' => 0 };

    my $results;
    if ($obj->{'id'}){
       $results = &get_profile_by_id($obj, $obj->{'id'});
    }
    elsif ($obj->{'profilename'}) {
       $results = &get_profile_by_profilename($obj, $obj->{'profilename'});
    }

    %$obj = (%$obj, %{$results}, '_cached' => 1) if ($results);
    return bless $obj, $pkg ;
}

###############################################################
# ACCESSOR METHODS
###############################################################
sub id {
    my $self = shift;
    @_ ? $self->{'id'} = shift : return $self->{'id'};
}

sub profilename {
    my $self = shift;
    @_ ? $self->{'profilename'} = shift : return $self->{'profilename'};
}

sub accessrights {
    my $self = shift;
    @_ ? $self->{'accessrights'} = shift : return $self->{'accessrights'};
}

###############################################################
# CORE METHODS
###############################################################
sub members {
    my $self = shift;
    my $members = $self->getMembers();
    return $members;
}

sub insert {
    my $self = shift;
    my $newProfile = {};
    foreach ('profilename','accessrights'){
       $::request->validation_errors("<div class='error_msg'>ERROR: $_ field is mandatory!</div>") 
                unless ($::request->{"profile_$_"});
       $newProfile->{$_} = $::request->{"profile_$_"};
    }

    return if ($::request->validation_errors);
    #commit to DB
    if ($self->_insert($newProfile)){
       #JS redirect
       return '<script language="Javascript" type="text/javascript">self.location="?view=admin&template=userProfiles"</script> ';
    }
    return 'Problems encountered in inserting new profile. Please check the logs!';
}
sub update {
    my $self = shift;
    my %updates = ();
    foreach ('profilename','accessrights'){
       $::request->validation_errors("<div class='error_msg'>ERROR: $_ field is mandatory!</div>") 
          unless ($::request->{"profile_$_"});
       $updates{$_} = $::request->{"profile_$_"};
    }

    return if ($::request->validation_errors);
    #commit to DB
    if ($self->_update(%updates)){
       #JS redirect
       return '<script language="Javascript" type="text/javascript">self.location="?view=admin&template=userProfiles"</script>';
    }
    return 'Problems encountered in updating the profile details. Please check the logs!';
}

sub delete {
   my $self = shift;
   my $id = shift || $self->id;
   my $result = $self->_delete($id);
   if ($result eq '0E0'){
      return "<div class=error_msg>Profile with ID '$id' does not exist.</div>";
   }
   elsif ($result){
      return "<div class=success_msg>Profile has been successfully deleted.</div>";
   }
   return "<div class=error_msg>Problems encountered in deleting the profile. Please check the logs!</div>";
}

############################################################################
# DB methods
############################################################################
sub get_profile_by_id {
   my $self = shift;
   my $id = shift || $self->id;
   return unless $id;
   $::dbquery{'get_profile_by_id'} ||= $::dbh->prepare(qq{SELECT id, 
   profilename, accessrights FROM profile WHERE id = ?
      }); 
   $::dbquery{'get_profile_by_id'}->execute($id);

   my $results;
   $results = $::dbquery{'get_profile_by_id'}->fetchrow_hashref
	     unless ($::dbquery{'get_profile_by_id'}->err);

   return $results;
}

sub get_profile_by_profilename {
   my $self = shift;
   my $profilename = shift || $self->profilename;
   return unless $profilename;
   $::dbquery{'get_profile_by_profilename'} ||= $::dbh->prepare(qq{SELECT id,
   profilename, accessrights FROM profile WHERE profilename = ?
      });
   $::dbquery{'get_profile_by_profilename'}->execute($profilename);

   my $results= {};
   $results = $::dbquery{'get_profile_by_profilename'}->fetchrow_hashref
             unless ($::dbquery{'get_profile_by_profilename'}->err);
   return $results;
}

sub _insert {
   my $self = shift;
   my $newProfile = shift;

   $::dbquery{'insert_profile'} ||= $::dbh->prepare(qq{INSERT INTO profile VALUES(NULL,?,?)});

   unless ($::dbquery{'insert_profile'}->execute($newProfile->{'profilename'},$newProfile->{'accessrights'})) 
   {
      ::syslog('error', 'Unable to insert new profile : '. $::dbh->errstr);
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
      $updates .= "$_ = '$val{$_}',";
   }
   chop $updates;

   my $result = $::dbh->do("UPDATE profile SET $updates WHERE id = $id", undef);
   unless ($result){
      ::syslog('error', "Unable to update profile '$id': $updates ". $::dbh->errstr);
      $::dbh->rollback;
      return;
   }
   return $result;
}

sub _delete {
   my $self = shift;
   my $id = shift;
   my $result;
   $result = $::dbh->do("DELETE FROM profile WHERE id = ?", undef, $id) 
      or ::syslog('error', "Unable to delete profile '$id': ". $::dbh->errstr);

   return $result;
}

sub getMembers {
   my $self = shift;
   $::dbquery{'getMembers'} ||= $::dbh->prepare(qq{SELECT id, username FROM usr WHERE profileid = ? });
   $::dbquery{'getMembers'}->execute($self->id);

   my $results;
   $results = $::dbquery{'getMembers'}->fetchall_arrayref( {} )
             unless ($::dbquery{'getMembers'}->err);

   return ($results || []);
}

1;
__END__

=item Clotho::Profile->new(%args)

Returns a Profile object with any additional attributes specified in I<%args>,
plus the data returned by an immediate call to the I<get_profile_details> method.
Normally, a new profile is created with a I<id> or I<profilename> by which to be identified.

=item $profile->getMembers()
It returns an  ARRAY_REF of the requested profile's member users

=item $profile->id([$value])

When called without any arguments, returns a scalar value which uniquely
identifies the profile to the storage backend. If called with an argument, sets the
value of the profile's id to I<$value>.

=cut
