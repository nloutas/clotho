package Clotho::User;
use strict;

use Clotho::Profile;
use Data::Dumper;

sub new {
    my $pkg  = shift;
    my $obj  = { @_, '_cached' => 0 };

    my $results;
    if ($obj->{'id'}){
       $results = &get_user_by_id($obj, $obj->{'id'});
    }
    elsif ($obj->{'username'}) {
       $results = &get_user_by_username($obj, $obj->{'username'});
    }
    else { #public user
       $results = &get_user_by_username($obj, 'visitor');
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

sub username {
    my $self = shift;
    @_ ? $self->{'username'} = shift : return $self->{'username'};
}

sub password {
    my $self = shift;
    @_ ? $self->{'password'} = shift : return $self->{'password'};
}

sub fullname {
    my $self = shift;
    @_ ? $self->{'fullname'} = shift : return $self->{'fullname'};
}

sub email {
    my $self = shift;
    @_ ? $self->{'email'} = shift : return $self->{'email'};
}

sub tel {
    my $self = shift;
    @_ ? $self->{'tel'} = shift : return $self->{'tel'};
}

sub profileid {
    my $self = shift;
    @_ ? $self->{'profileid'} = shift : return $self->{'profileid'};
}

sub disabled {
    my $self = shift;
    @_ ? $self->{'disabled'} = shift : return $self->{'disabled'};
}

sub updatedate {
    my $self = shift;
    @_ ? $self->{'updatedate'} = shift : return $self->{'updatedate'};
}

###############################################################
# CORE METHODS
###############################################################
sub login {
    my $self = shift;
    my %user = ();
    foreach ('username','password'){
       $::request->validation_errors("<div class='error_msg'>ERROR: $_ is mandatory!</div>") 
                unless ($::request->{"login_$_"});
       $user{$_} = $::request->{"login_$_"};
    }
    return if ($::request->validation_errors);

    if ($self->authenticate(%user)){
       $::request->cookie( $::query->cookie(
                               -name    => 'clotho_login',
                               -value   => $self->id,
                              #-domain  => $ENV{'SERVER_NAME'},
                               -path    => '/')
                         );
       #JS redirect
       return '<script language="Javascript" type="text/javascript">self.location="?view=admin"</script> ';
    }
    return 'Invalid credentials! Please try again.';
}

sub logout {
    my $self = shift;

    $::request->cookie( $::query->cookie(
                               -name    => 'clotho_login',
                               -value   => '',
                              #-domain  => $ENV{'SERVER_NAME'},
                               -path    => '/')
                      );

    #JS redirect
    return '<script language="Javascript" type="text/javascript">self.location="?"</script> ';
}

sub admin {
    my $self = shift;
    return ($self->profileid == 2);
}

sub editor {
    my $self = shift;
    return ($self->profileid == 3);
}

sub public {
    my $self = shift;
    return ($self->profileid == 1);
}

sub editPage {
    my $self = shift;
    return 1 if ($self->admin);
    return 1 if ($self->editor && !$::page->retired);
    return;
}

sub memberof {
    my $self = shift;
    return ($self->profileid == shift);
}

sub profile {
    my $self = shift;
    $self->{'profile'} ||= new Clotho::Profile(id => $self->profileid);
    return $self->{'profile'};
}

sub insert {
    my $self = shift;
    my $newUser = {};
    foreach ('username','password','password_confirm','profileid'){
       $::request->validation_errors("<div class='error_msg'>ERROR: $_ field is mandatory!</div>") 
                unless ($::request->{"user_$_"});
       $newUser->{$_} = $::request->{"user_$_"};
    }

    $::request->validation_errors("<div class='error_msg'>ERROR: the 'password' is not identical to the 'password_confirm' field!</div>")
             unless ($newUser->{'password'} eq $newUser->{'password_confirm'});

    foreach ('fullname','email','tel'){
       $newUser->{$_} = $::request->{"user_$_"};
    }

    return if ($::request->validation_errors);
    #commit to DB
    if ($self->_insert($newUser)){
       #JS redirect
       return '<script language="Javascript" type="text/javascript">self.location="?view=admin&template=adminUsers"</script> ';
    }
    return 'Problems encountered in inserting new user. Please check the logs!';
}
sub update {
    my $self = shift;
    my %updates = ();
    foreach ('username','profileid'){
       $::request->validation_errors("<div class='error_msg'>ERROR: $_ field is mandatory!</div>") 
          unless ($::request->{"user_$_"});
       $updates{$_} = $::request->{"user_$_"};
    }

    if ($::request->{'user_password'}){
       $updates{'password'} = $::request->{'user_password'};
       $updates{'password_confirm'} = $::request->{'user_password_confirm'};
       $::request->validation_errors("<div class='error_msg'>ERROR: the 'password' is not identical to the 'password_confirm' field!</div>")
          unless ($updates{'password'} eq $updates{'password_confirm'});
    }

    foreach ('fullname','email','tel','disabled'){
       $updates{$_} = $::request->{"user_$_"};
    }
    
    return if ($::request->validation_errors);
    #commit to DB
    if ($self->_update(%updates)){
       #JS redirect
       return '<script language="Javascript" type="text/javascript">self.location="?view=admin&template=adminUsers"</script>';
    }
    return 'Problems encountered in updating the user details. Please check the logs!';
}

sub delete {
   my $self = shift;
   my $id = shift || $self->id;
   my $result = $self->_delete($id);
   if ($result eq '0E0'){
      return "<div class=error_msg>User with ID '$id' does not exist.</div>";
   } 
   elsif ($result){
      return "<div class=success_msg>User has been successfully deleted.</div>";
   }
   return "<div class=error_msg>Problems encountered in deleting the user. Please check the logs!</div>";
}
############################################################################
# DB methods
############################################################################
sub get_user_by_id {
   my $self = shift;
   my $id = shift || $self->id;
   return unless $id;
   $::dbquery{'get_user_by_id'} ||= $::dbh->prepare(qq{SELECT id, 
   username, password, fullname, email, tel, profileid,
   disabled, DATE_FORMAT(updatedate, '%d/%m/%Y') as updatedate
   FROM usr WHERE id = ?
      }); 
   $::dbquery{'get_user_by_id'}->execute($id);

   my $results= {};
   $results = $::dbquery{'get_user_by_id'}->fetchrow_hashref
	     unless ($::dbquery{'get_user_by_id'}->err);
   return $results;
}

sub get_user_by_username {
   my $self = shift;
   my $username = shift || $self->username;
   return unless $username;
   $::dbquery{'get_user_by_username'} ||= $::dbh->prepare(qq{SELECT id,
   username, password, fullname, email, tel, profileid,
   disabled, DATE_FORMAT(updatedate, '%d/%m/%Y') as updatedate
   FROM usr WHERE username = ?
      });
   $::dbquery{'get_user_by_username'}->execute($username);

   my $results= {};
   $results = $::dbquery{'get_user_by_username'}->fetchrow_hashref
             unless ($::dbquery{'get_user_by_username'}->err);
   return $results;
}

sub _insert {
   my $self = shift;
   my $newUser = shift;

   $::dbquery{'insert_user'} ||= $::dbh->prepare(qq{INSERT INTO usr VALUES(NULL,?,?,?,?,?,?,0,now())});

   unless ($::dbquery{'insert_user'}->execute($newUser->{'username'},$newUser->{'password'},$newUser->{'fullname'},$newUser->{'email'},$newUser->{'tel'},$newUser->{'profileid'} )) {
      ::syslog('error', 'Unable to insert new user : '. $::dbh->errstr);
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

   my $result = $::dbh->do("UPDATE usr set updatedate = now() $updates WHERE id = $id", undef);
   unless ($result){
      ::syslog('error', "Unable to update user '$id': $updates ". $::dbh->errstr);
      $::dbh->rollback;
      return;
   }
   return $result;
}

sub disable {
   my $self = shift;
   return $self->update('disabled' => 1);
}

sub _delete {
   my $self = shift;
   my $id = shift;
   my $result;
   $result = $::dbh->do("DELETE FROM usr WHERE id = ?", undef, $id) 
      or ::syslog('error', "Unable to delete user '$id': ". $::dbh->errstr);

   return $result;
}
sub authenticate {
   my $self = shift;
   my %user = @_;
   $::dbquery{'authenticate_user'} ||= $::dbh->prepare(qq{SELECT id 
   FROM usr WHERE username = ? AND password = ENCRYPT(?,'pi')
      }); 
   $::dbquery{'authenticate_user'}->execute($user{'username'},$user{'password'});

   $self->{'id'} = $::dbquery{'authenticate_user'}->fetchrow
	     unless ($::dbquery{'authenticate_user'}->err);

   return $self->{'id'};
}
1;
__END__

=item Clotho::User->new(%args)

Returns a User object with any additional attributes specified in I<%args>,
plus the data returned by an immediate call to the I<get_user_details> method.
Normally, a new user is created with a I<id> or I<username> by which to be identified.

=item $user->user_profile()
It returns an  ARRAY_REF of this user's profile ids 

=item $user->get_profile()
It returns an  ARRAY_REF of the requested profile's name and access rights


=item $user->id([$value])

When called without any arguments, returns a scalar value which uniquely
identifies the user to the storage backend. If called with an argument, sets the
value of the user's id to I<$value>.


=cut
