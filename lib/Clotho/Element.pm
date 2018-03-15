package Clotho::Element;

use XML::Simple;
use CGI;
use Data::Dumper;
use strict;

sub new {
    my $ref = shift;
    my $obj = { @_ };
    &get_element_details($obj) if ($obj->{'id'});
    &parseContent($obj); #parse the element content

    my $class = $obj->{'type'} ? "Clotho::Element::".$obj->{'type'} : $ref;
    eval qq{ require $class };
    return ::syslog('error', "require $class error '$@'") if $@;
    bless $obj, $class;
    $obj->fields() if ($::request->private_view); #define element fields
    return $obj;
}

sub class {
    my $self = shift;
    return ref $self;
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

sub type {
    my $self = shift;
    return $self->{'type'};
}

sub templateid {
    my $self = shift;
    @_ ? $self->{'templateid'} = shift : return $self->{'templateid'};
}

sub updatedate {
    my $self = shift;
    @_ ? $self->{'updatedate'} = shift : return $self->{'updatedate'};
}

###############################################################
# CORE METHODS
###############################################################

sub parseContent {
    my $self = shift;

    unless ($self->{'content'}){
       my $XML = ($::request->private_view) ? $self->{'privcontent'} : $self->{'pubcontent'};
#::syslog('debug', "XML: ". Dumper($XML));
       return unless $XML;
       $self->{'content'} = eval {(new XML::Simple(forcearray => 0, SuppressEmpty => 1))->XMLin("$XML")};
       return ::syslog('error', "Invalid XML '$XML': $@") if($@);
    }

#::syslog('debug', "content: ". Dumper($self->{'content'}));
    return $self->{'content'};
}

sub commit {
    my $self = shift;
    $self->{'pubcontent'} = $self->{'privcontent'};
    return ($self->_update('pubcontent' => $self->{'pubcontent'}));
}

sub changed {
    my $self = shift;
    return ( $self->{'pubcontent'} ne $self->{'privcontent'} );
}

sub template {
    my $self = shift;

    unless ($self->{'template'}){
       $self->{'template'} = new Clotho::Template(id => $self->templateid);
    }
    return $self->{'template'};
}

sub adminForm {
    my $self = shift;

    my $form = '';

    foreach my $field (@{$self->{'fields'}}){
       if ($field->{'mandatory'}){
          $form .= qq{<div class="mandatory">$field->{'title'}* \n};
       } else {
          $form .= qq{<div class="optional">$field->{'title'} \n};
       }
       $form .= $::request->hint($field->{'hint'});

       my $field_content = $self->{'content'}->{$field->{'name'}} || $field->{'default'};
       if ($field->{'fieldType'} eq 'textarea'){
          $form .= qq{<textarea name="element_$field->{'name'}" cols="100" rows="$field->{'length'}" style="vertical-align: middle;">}. $field_content . qq{</textarea>};
       }
       elsif ($field->{'fieldType'} eq 'text' || $field->{'fieldType'} eq 'dat'){
          $form .= qq{<input type="text" value="}. $field_content . qq{" name="element_$field->{'name'}" size="$field->{'length'}">};
       }
       elsif ($field->{'fieldType'} eq 'select'){
          $form .= qq{<select name="element_$field->{'name'}">};
          foreach my $option (@{$field->{'options'}}){
             $form .= qq{<option value="$option"} . ($option eq $field_content ? ' selected': '') . qq{>$option</option>};
          }
          $form .= qq{</select>};
       }
       elsif ($field->{'fieldType'} eq 'date'){
          $field_content ||= $::request->today;
          my @date = split "/", $field_content;

          $form .= qq{<input type="text" value="}. $field_content . qq{" name="element_$field->{'name'}" size="$field->{'length'}"> <a href="javascript:cal_$field->{'name'}.popup();"><img src="$::request->{'static_vars'}{'imgpath'}/calendar.gif" width="16" height="16" border="0" alt="Select the date"></a> 
<script language="JavaScript" src="$::request->{'static_vars'}{'jspath'}/calendar.js"></script> 
<script language="JavaScript"> 
var STATIC_PATH="$::request->{'static_vars'}{'basepath'}"; 
var cal_$field->{'name'} = new calendar (document.forms['adminform'].elements['element_$field->{name}']);
cal_$field->{'name'}.year_scroll = true;
cal_$field->{'name'}.time_comp = false;
</script> 
	  };
       }
       elsif ($field->{'fieldType'} eq 'richtextarea'){
          $form .= qq{<input type="hidden" name="element_$field->{'name'}" value="}. ($self->esc_content($field_content) || '&nbsp;') . qq{" />};
	  $::tt->process('richtext_buttons.wml', $::request, \$form);  # append rich text buttons
	  $form .= qq{
<iframe name="frame_$field->{'name'}" id="$field->{'name'}" class="richFrame" ></iframe>
<script language="Javascript" src="$::request->{'static_vars'}{'jspath'}/richTextEditor.js"></script>};
       }
       elsif ($field->{'fieldType'} eq 'hidden'){
          $form .= qq{<input type="hidden" name="element_$field->{'name'}" value="}.($field_content).qq{" />};
       }
       $form .= "\n</div>\n";
    }

   return $form;
}

sub insert {
    my $self = shift;
    $self->templateid($self->default_templateid);
    if ($::request->{'element_name'}){
       $self->name($::request->{'element_name'});
    }
    else { 
       $self->{'validation_errors'} = "<div class='error_msg'>ERROR: NAME field is mandatory!</div>";
    }
    $self->{'privcontent'} = $self->validate();
    $self->{'pubcontent'} = $self->{'privcontent'};

    return if ($self->{'validation_errors'});
    #commit to DB and JS redirect
    if ($self->_insert() && $self->get_max_element_id){
       unless ($::page->update_area($self->id) =~ /^Error/){
          return '<script language="Javascript" type="text/javascript">self.location="?view=edit"</script>';
       }
    }
    return 'An error occurred while inserting new element. Please check the logs!';
}
sub update {
    my $self = shift;
    my %updates = ( 'name' => ($::request->{'element_name'} || $self->name),
                    'privcontent' => $self->validate(),
                  );
    return if ($self->{'validation_errors'});

    #commit to DB and JS redirect
    if ($self->_update(%updates)){
       return '<script language="Javascript" type="text/javascript">self.location="?view=edit"</script> '; 
    }
    return 'An error occurred while updating the element details. Please check the logs!';
}
sub delete {
    my $self = shift;
    my $id = $self->id;
    if (my $pagerefs = $self->referenced){
       return "<div class='error_msg'>Element $id cannot be deleted! It is being referenced by $pagerefs page(s).</div>";
    }

    if ($self->_delete($id)){
       return "<div class='success_msg'>Element $id has been deleted.</div>"; 
    }
    return "<div class='error_msg'>An error occurred while deleting element $id.Please check the logs!</div>";
}

sub validate {
    my $self = shift;
    my $content = '<CONTENT>';
    foreach my $field (@{$self->{'fields'}}){
       if ($field->{'mandatory'} && !$::request->{"element_$field->{'name'}"}){
          $self->{'validation_errors'} .= "<div class='error_msg'>ERROR: $field->{'title'} field is mandatory!</div>";
       }
       else {
          $content .= "<$field->{'name'}>" . $self->esc_content($::request->{"element_$field->{'name'}"}) . "</$field->{'name'}>";
       }
    }

    return $content . '</CONTENT>';
}

sub esc_content {
    my $self = shift;
    my $s = shift ;
    return unless defined $s;
    $s =~ s,& ,&amp; ,g;
    $s =~ s,\<,\&lt;,g;
    $s =~ s,\>,\&gt;,g;
    $s =~ s,\",&quot;,g; 
    $s =~ s,\',\\',g; 
    #$s =~ s,\',&#146;,g; 
    return $s;
}

sub strip_html {
    my $self = shift;
    my $text = shift;
    $text =~ s/<[#'=&;:"\+\-\s\/\?\.\w]*>//g;
    return  $text;
}
############################################################################
# DB methods
############################################################################

sub get_element_details {
   my $self = shift;
   
   $::dbquery{'get_element_details'} ||= $::dbh->prepare(qq{SELECT id, name,
   type, templateid, pubcontent, privcontent, DATE_FORMAT(updatedate, '%d/%m/%Y') as updatedate
   FROM element WHERE id = ?
      }); 
   $::dbquery{'get_element_details'}->execute($self->{'id'});

   my $results= {};
   $results = $::dbquery{'get_element_details'}->fetchrow_hashref
	     unless ($::dbquery{'get_element_details'}->err);
   
   if ($results){
      %$self = (%$self, %{$results});
   }
   else {
      ::syslog('error', "Element with id '".$self->{'id'} ."' is not present in the DB!");
   }
}

sub get_max_element_id {
   my $self = shift;
   
   $::dbquery{'get_max_element_id'} ||= $::dbh->prepare(qq{SELECT max(id) FROM element});
   $::dbquery{'get_max_element_id'}->execute;
   my $id = $::dbquery{'get_max_element_id'}->fetchrow;
   $self->id($id) if ($id);
}
sub _insert {
   my $self = shift;
   $::dbquery{'insert_element'} ||= $::dbh->prepare(qq{INSERT INTO element VALUES(NULL,?,?,?,?,?,now())});

   unless ( $::dbquery{'insert_element'}->execute($self->{'name'},$self->{'type'},$self->{'templateid'},$self->{'pubcontent'},$self->{'privcontent'})) {
      ::syslog('error', 'Unable to insert new element : '. $::dbh->errstr);
      $::dbh->rollback;
      return;
   }
   $::dbh->commit;

   return 1;
}

sub _update {
   my $self   = shift;
   my %val    = @_;
   return unless (%val);
   my $id = $self->id;

   my $sql = 'UPDATE element SET updatedate = now()';
   foreach (keys %val){
       $sql .= ", $_ = " . $::dbh->quote($val{$_});
   }
   $sql .= " WHERE id = $id";

   my $result;
   $result = $::dbh->do($sql, undef)
      or ::syslog('error', "Unable to update element '$id': ". $::dbh->errstr);

   return $result;
}

sub _delete {
   my $self = shift;
   my $id = shift;
   my $result;
   $result = $::dbh->do("DELETE FROM element WHERE id = ?", undef, $id)
      or ::syslog('error', "Unable to delete element '$id': ". $::dbh->errstr);
   return $result;
}

sub referenced {
   my $self = shift;
   my $condition = "%<ELEMENTID>$self->{'id'}</ELEMENTID>%";

   $::dbquery{'get_referenced'} ||= $::dbh->prepare(qq{SELECT count(1)
   FROM page WHERE public_elements LIKE ? OR private_elements LIKE ? });
   $::dbquery{'get_referenced'}->execute($condition,$condition);

   my $results; 
   $results = $::dbquery{'get_referenced'}->fetchrow
             unless ($::dbquery{'get_referenced'}->err);
   return $results;
}
############################################################################
# Virtual methods to be overriden by Element subclasses
############################################################################

# Default Template ID 
sub default_templateid {
    return 2;
}


1;
__END__

=item Clotho::element->new(%args)

Returns an empty unpopulated element object with any additional attributes
specified in I<%args>. element data is normally populated 
by a subsequent call to I<$element->get_element_details>.
Minimally, a new element is normally populated with an id by which it can be
identified to the storage backend.


=item $element->commit

Sets the element's current content for the 'public' status. Any
subsequent calls to the I<$storage->store> method on this element will save the
updated 'public' status permanently. Otherwise, if not subsequently stored, this
altered status will only persist for the life of the current request.

=item $element->changed

Returns true if the content held for the 'public' status of the element is different to
that held for the 'private' status. A true value therefore indicates that there
are uncommitted changes on this object. 

=cut
