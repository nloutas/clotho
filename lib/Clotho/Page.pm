package Clotho::Page;
use strict;
use Clotho::Template;
use Clotho::Element;
use Clotho::User;
use XML::Simple;

use Data::Dumper;

sub new {
    my $pkg  = shift;
    my $obj  = { @_, '_cached' => 0 };
    bless $obj, $pkg;

    my $results;
    if ($obj->{'id'}){
       $results = $obj->get_page_by_id($obj->{'id'});
    }
    elsif ($obj->{'path'}) {
       $results = $obj->get_page_by_path($obj->{'path'});
    }

    %$obj = (%$obj, %{$results}, '_cached' => 1) if ($results);
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
    @_ ? $self->{'name'} = shift : return pack "U0C*", unpack "C*", $self->{'name'};
}

sub simplename {
    my $self = shift;
    @_ ? $self->{'simplename'} = shift : return $self->{'simplename'};
}

sub path {
    my $self = shift;
    @_ ? $self->{'path'} = shift : return $self->{'path'};
}

sub templateid {
    my $self = shift;
    @_ ? $self->{'templateid'} = shift : return $self->{'templateid'};
}

sub statusid {
    my $self = shift;
    @_ ? $self->{'statusid'} = shift : return $self->{'statusid'};
}

sub authorid {
    my $self = shift;
    @_ ? $self->{'authorid'} = shift : return $self->{'authorid'};
}

sub textcontent {
    my $self = shift;
    @_ ? $self->{'textcontent'} = shift : return pack "U0C*", unpack "C*", $self->{'textcontent'};
}

sub keywords {
    my $self = shift;
    @_ ? $self->{'keywords'} = shift : return pack "U0C*", unpack "C*", $self->{'keywords'};
}

sub deleted {
    my $self = shift;
    @_ ? $self->{'deleted'} = shift : return $self->{'deleted'};
}

sub updatedate {
    my $self = shift;
    @_ ? $self->{'updatedate'} = shift : return $self->{'updatedate'};
}

sub depth {
    my $self = shift;
    @_ ? $self->{'depth'} = shift : return $self->{'depth'};
}

###############################################################
# CORE METHODS
###############################################################
sub type {
    my $self = shift;
    if ($self->simplename =~ m/\.(\w{3})$/){
       return Clotho::Config->filetype($1) || 'text/html';
    }
    return 'text/html';
}

sub live {
    my $self = shift;
    return ($self->statusid == 2);
}

sub retired {
    my $self = shift;
    return ($self->statusid == 3);
}

sub author {
    my $self = shift;
    $self->{'author'} ||= new Clotho::User(id => $self->{'authorid'});
    return $self->{'author'};
}

sub elements {
    my $self = shift;
    my $XML  = $::request->private_view ? $self->{'private_elements'} : $self->{'public_elements'};
    return unless $XML;
    #$XML =~ s/<\?xml .*\?>//;

    $self->{'elements'} = eval {(new XML::Simple(forcearray => 1))->XMLin("$XML")};
    return ::syslog('error', "Invalid XML '$XML': $@") if($@);
#::syslog('debug', "elements: ". Dumper($self->{'elements'}));

    return $self->{'elements'};
}

sub get_elements {
    my $self = shift;
    my $refresh = shift;
    delete $self->{'element_list'} if ($refresh);

    unless ($self->{'element_list'}){
       my $elements  = $self->elements;
       foreach my $area (sort keys %{$elements->{'AREA'}}) {
           foreach my $elementid ( @{ $elements->{'AREA'}->{$area}->{'ELEMENTID'} } ) {
              push @{$self->{'element_list'}{$area}}, new Clotho::Element(id => $elementid);
           }
       }
    }
#::syslog('debug', " element_list:". Dumper($self->{'element_list'}));

    return $self->{'element_list'};
}

sub changed {
    my $self = shift;
    my $request = shift;

    if ( $self->{public_elements} ne $self->{private_elements} ) {
        return 1;
    }

    my $elements = $self->get_elements;
    foreach my $area (keys %$elements) {
        foreach ( @{ $elements->{$area} } ) {
            return 1 if $_->changed();
        }
    }
    return 0;
}

sub template {
    my $self = shift;

    unless ($self->{'template'}){
       #present Requested template or this page's template or the '404 ERROR' template
       my $templateid = $::request->templateid || $self->templateid || '3';
       $self->{'template'} = new Clotho::Template(id => $templateid);
    }
    return $self->{'template'};
}
sub link {
    my $self = shift;
    my $classname = shift;
    my $link_url = $self->path;
    $link_url .= '?view='.$::request->view if ($::request->view ne 'public');
    return qq{<a href="$link_url" class="$classname">}. $self->name . q{</a>};
}

sub sitemapLink {
    my $self = shift;
    my $spaces = shift || 0;
    my $sign = '';
    foreach (1..$spaces){ $sign .= '&nbsp;'x3; }
    $sign .= '<img src="'.$::request->{'static_vars'}{'imgpath'}.'/leaf_node-0minus.gif">' 
             unless ($self->{'rootNode'});
   
    my $link_url = $self->path;
    if ($::request->referer =~ /\?view=(\w*)/){
        $link_url .= '?view='.$1;
    }
    return qq{<div onmouseover="window.status='$link_url'; this.className='sitemapLinkHover';" onmouseout="window.status=''; this.className='sitemapLink';" onclick="sitemapLink('$link_url')" class="sitemapLink">$sign}. $self->name . q{</div>};
}

my %status_action = ( 1 => 'publish', 2 => 'archive', 3 => 'republish' );
sub adminLink {
    my $self = shift;
    my $spaces = shift;
    $self->{'adminLink'} = '<td class="sitemap">'.$self->sitemapLink($spaces).'</td>';

    my $st = $self->statusid == 3 ? -1 : 1;
    my @linkname = ('edit', $status_action{$self->statusid});
    push @linkname, ($self->{'rootNode'} ? '' : 'delete');
    my @linktarget = ('?view=admin&template=editPage','?view=edit&update_status='.$st,'?view=edit&delPage='.$self->id);
    my $i = 0;
    foreach my $linkname (@linkname){
       $self->{'adminLink'} .= q{<td class="sitemap"><a href="}.$self->path.$linktarget[$i++].qq{" class="adminLink" target="new">$linkname</a> </td>};
    }
    return $self->{'adminLink'};
}

sub children {
    my $self = shift;
    my $depth= shift;

    unless ($self->{'children'}){
       my $children = $self->get_children;
       foreach (@$children){
          my $child = new Clotho::Page(id=>$_->{'id'}, name=>$_->{'name'}, path=>$_->{'path'}, depth=>$depth);
          push @{$self->{'children'}}, $child;
          if ($depth){
	     my $grandchildren = $child->children($depth-1);
	     push @{$self->{'children'}}, @{$grandchildren} if ($grandchildren);
          }
       }
    }
#::syslog('error', " children:". Dumper($self->{'children'}));
    return ($self->{'children'} || []);
}

sub area {
    my $self = shift;
    my $args = shift;
#::syslog('error', " area args:". Dumper($args));
    
    my $name   = $args->{name};
    my $locked = $args->{locked} || 0;
    my @types  = $args->{types} ? @{$args->{types}} : Clotho::Config->elements();

    my $admin_view = $::request->private_view() && $::request->user->editPage;
    my $out = '';

    foreach my $element (@{$self->{'element_list'}{"$name"}}){
       my $element_out = $element->template->process({ element => $element });
       if ($admin_view) {
          $out .= '<div id="element_'. $element->id . '" class="element" elementid="'. $element->id . '" type="' . $element->type . '">' . $element_out. '</div>';
       } else {
          $out .= $element_out;
       }
    } 

    if ($admin_view) {
        $out ||= '<div id="emptyElement" class="element" elementid="0" type="">Empty area</div>';
	$out = qq{<div id="area_$name" areaid="$name" class="area" locked="$locked" permittype="} . (join ":", @types) .qq{">\n$out\n</div>\n};
    }
    return $out;
}

sub update_area {
    my $self = shift;
    my $elementid = shift;

    $self->elements; # retrieve $self->{'elements'}
    #insert a new elementid in the area
    if ($elementid){
       if ($self->{'elements'}->{'AREA'}->{$::request->{'area'}}->{'ELEMENTID'}){
          my @my_area = @{$self->{'elements'}->{'AREA'}->{$::request->{'area'}}->{'ELEMENTID'}};
          my @b = splice(@my_area, 0, $::request->{'areaoffset'});
          @{$self->{'elements'}->{'AREA'}->{$::request->{'area'}}->{'ELEMENTID'}} = (@b,$elementid,@my_area);
       }
       else {
          $self->{'elements'}->{'AREA'}->{$::request->{'area'}}->{'ELEMENTID'} = [$elementid];
       }
    }
    #update the area with element moves and removes
    elsif ($::request->{'updateArea'}){
       foreach my $area (split '%', $::request->{'updateArea'}){
          my ($area_name, $area_elements) = split ':', $area;
          @{$self->{'elements'}->{'AREA'}->{$area_name}->{'ELEMENTID'}} = split ",", $area_elements;
       }
    }

    $self->{'private_elements'} = (new XML::Simple(forcearray => 1))->XMLout($self->{'elements'}, RootName => 'ELEMENTS', XMLDecl => '<?xml version="1.0" encoding="UTF-8"?>');

    if ($self->_update('private_elements' => $self->{'private_elements'})){
       $self->get_elements(1); # Refresh $self->{'element_list'}
       return 'Page changes saved. ';
    }
    return 'Error! Unable to save changes for the page. ';
}

sub update_status {
    my $self = shift;
    my $statusid = $self->statusid + $::request->{'update_status'};
    $self->statusid($statusid);
    if ($self->_update(statusid => $self->statusid)){
       return ' Page status updated! ';
    }
    return ' Error! Unable to update page status. ';
}

sub commit {
    my $self = shift;
    #commit element changes
    my $elements = $self->get_elements;
    foreach my $area (keys %$elements) {
        foreach ( @{ $elements->{$area} } ) {
            $_->commit() if $_->changed();
        }
    }

    #commit area changes
    $self->{public_elements} = $self->{private_elements};
    if ($self->_update('public_elements' => $self->{'public_elements'})){
       return ' Page commited successfully. ';
    }
    return ' Error! Unable to commit changes for the page. ';
}

sub insert {
    my $self = shift;
    my $newpage = {};
    foreach ('name','simplename','templateid'){
       return "ERROR: $_ field is mandatory!" unless ($::request->{"page_$_"});
       $newpage->{$_} = $::request->{"page_$_"};
    }
    $newpage->{'path'} = $self->path . $newpage->{'simplename'}. '/';
    $newpage->{'keywords'} = $::request->{'page_keywords'};
    $newpage->{'textcontent'} = join " ", $newpage->name, $newpage->keywords;
    #commit to DB
    if ($self->_insert($newpage)){
       #JS redirect
       return '<script language="Javascript" type="text/javascript">self.location="' . $newpage->{'path'} . '?view=edit"</script> '; 
    }
    return 'Problems encountered in inserting new page. Please check the logs!';
}
sub update {
    my $self = shift;
    my %updates = ();
    foreach ('name','simplename'){
       return "ERROR: $_ field is mandatory!" unless ($::request->{"page_$_"});
       $updates{$_} = $::request->{"page_$_"};
    }
    #update path
    if ($updates{'simplename'} ne $self->simplename){
       ($updates{'path'} = $self->{'path'}) =~ s,/\Q$self->{'simplename'}\E(/)?$,/\Q$updates{'simplename'}\E$1,;
    }
    $updates{'keywords'} = $::request->{'page_keywords'};
#print STDERR "\n update; ". $self->simplename. Dumper(\%updates);
    #commit to DB
    if ($self->_update(%updates)){
       #JS redirect
       return '<script language="Javascript" type="text/javascript">self.location="'.$updates{'path'}.'?view=edit"</script> '; 
    }
    return 'Problems encountered in updating the page details. Please check the logs!';
}
############################################################################
# DB methods
############################################################################
sub get_page_by_id {
   my $self = shift;
   my $id = shift || $self->id;
   return unless $id;
   $::dbquery{'get_page_by_id'} ||= $::dbh->prepare(qq{SELECT id, name, simplename, 
   path, templateid, statusid, authorid, public_elements, private_elements, textcontent, keywords,
   deleted, DATE_FORMAT(updatedate, '%d/%m/%Y') as updatedate
   FROM page WHERE id = ?
      }); 
   $::dbquery{'get_page_by_id'}->execute($id);

   my $results= {};
   $results = $::dbquery{'get_page_by_id'}->fetchrow_hashref
	     unless ($::dbquery{'get_page_by_id'}->err);
#::syslog('error', " get_page_by_id: $id ". Dumper($results));
   return $results;
}

sub get_page_by_path {
   my $self = shift;
   my $path = shift || $self->path;
   return unless $path;
   $path .= '/' unless ($path =~ /\/$/);
   $::dbquery{'get_page_by_path'} ||= $::dbh->prepare(qq{SELECT id, name, simplename, 
   path, templateid, statusid, authorid, public_elements, private_elements, textcontent, keywords,
   deleted, DATE_FORMAT(updatedate, '%d/%m/%Y') as updatedate
   FROM page WHERE path = ?
      });
   $::dbquery{'get_page_by_path'}->execute($path);

   my $results= {};
   $results = $::dbquery{'get_page_by_path'}->fetchrow_hashref
             unless ($::dbquery{'get_page_by_path'}->err);
   return $results;
}

sub get_children {
   my $self = shift;

   my $delete_condition = $::request->private_view ? '' : 'deleted = 0 AND';
   $::dbquery{'get_children'} ||= $::dbh->prepare(qq{SELECT id, name, path
   FROM page WHERE $delete_condition parentid = ? 
      }); 
   $::dbquery{'get_children'}->execute($self->id);
   my $results;
   $results = $::dbquery{'get_children'}->fetchall_arrayref( {} )
	     unless ($::dbquery{'get_children'}->err);

   return ($results || []);
}

sub _insert {
   my $self = shift;
   my $newpage = shift;
#::syslog('error', " _insert: ". Dumper($newpage));

   $::dbquery{'insert_page'} ||= $::dbh->prepare(qq{INSERT INTO page VALUES (NULL,?,?,?,?,1,?,?,?,?,?,?,0,now())});
   unless ($::dbquery{'insert_page'}->execute($newpage->{'name'},$newpage->{'simplename'},$newpage->{'path'},$newpage->{'templateid'},$::request->user->id,$self->id,$newpage->{'public_elements'},$newpage->{'private_elements'},$newpage->{'textcontent'},$newpage->{'keywords'})) {
      ::syslog('error', 'Unable to insert new page : '. $::dbh->errstr);
      $::dbh->rollback;
      return;
   }

   return 1;
}

sub _update {
   my $self = shift;
   my %val  = @_;
   return unless (%val);
   my $id   = $self->id;
   my $sql = 'UPDATE page SET updatedate = now()';
   foreach (keys %val){
      $sql .= ", $_ = '$val{$_}'";
   }
   $sql .= " WHERE id = $id";

   my $result;
   $result = $::dbh->do("$sql", undef) 
      or ::syslog('error', "Unable to update page '$id': ". $::dbh->errstr);

   return $result;
}

sub delete {
   my $self = shift;
   my $id = shift || $self->id;
   return ' Error! The Home Page cannot be deleted. ' if ($id == 1);
#::syslog('error', "page id to delete :'$id' ");
   my $delPage = ($id == $self->id) ? $self : new Clotho::Page(id => $id);
   if ($delPage->_update(deleted => 1)){
      return ' Page deleted! ';
   }
   return ' Error! Unable to delete the page. ';
}

sub _erase_ {
   my $self = shift;
   my $id = shift || $self->id;
   my $result;
   $result = $::dbh->do("DELETE FROM page WHERE id = ?", undef, $id) 
      or ::syslog('error', "Unable to delete page '$id': ". $::dbh->errstr);

   return $result;
}

sub get_status_name {
   my $self = shift;

   $::dbquery{'get_status'} ||= $::dbh->prepare(qq{SELECT name FROM status WHERE id = ?});
   $::dbquery{'get_status'}->execute($self->statusid);
   my $status_name;
   $status_name = $::dbquery{'get_status'}->fetchrow
             unless ($::dbquery{'get_status'}->err);

   return ($status_name || 'Unknown status');
}

sub available_templates {
   my $self = shift;
   $::dbquery{'available_templates'} ||= $::dbh->prepare(qq{SELECT id, name FROM template WHERE hidden = 0 });
   $::dbquery{'available_templates'}->execute();
   my $templates = [];
   $templates = $::dbquery{'available_templates'}->fetchall_arrayref( {} )
             unless ($::dbquery{'available_templates'}->err);

   return ($templates);
}

1;
__END__

=item Clotho::Page->new(%args)

Returns a Page object with any additional attributes specified in I<%args>,
plus the data returned by an immediate call to the I<get_page_details> method.
Normally, a new page is created with a I<id> or I<path> by which it can be identified.

=item $page->elements()
all the page's public_elements and private_elements are stored in XML format in the DB
e.g. 
 <?xml version="1.0" encoding="UTF-8"?>
<ELEMENTS>
   <AREA id="main">
       <ELEMENTID>1</ELEMENTID>
       <ELEMENTID>3</ELEMENTID>
   </AREA>
   <AREA id="bottom">
       <ELEMENTID>2</ELEMENTID>
   </AREA>
</ELEMENTS>

The XML::Simple module is used to parse and return a data structure in the form
$VAR1 = {
          'AREA' => {
                    'bottom' => {
                                'ELEMENTID' => [
                                               '2'
                                             ]
                              },
                    'main' => {
                              'ELEMENTID' => [
                                             '1',
                                             '3'
                                           ]
                            }
                  }
        };


=item $page->get_elements()
It returns an  ARRAY_REF of Element objects for each Area
e.g. 
$VAR1 = {
          'bottom' => [
                      bless( {
                               'id' => '2'
                             }, 'Clotho::Element' )
                    ],
          'main' => [
                    bless( {
                             'id' => '1'
                           }, 'Clotho::Element' ),
                    bless( {
                             'id' => '3'
                           }, 'Clotho::Element' )
                  ]
        };


=item $page->id([$value])

When called without any arguments, returns a scalar value which uniquely
identifies the page to the storage backend. If called with an argument, sets the
value of the page's id to I<$value>.


=item $page->commit
Publishes the page's private elements to public elements. Any
subsequent calls to the I<$page->update> method on this page will save the
updated 'public' elements permanently. Otherwise, if not subsequently stored, the
altered 'public' elements will only persist for the life of the current request.

=item $page->changed

Returns true if the private elements of the page are different from the 'public' elements.
Thus, a true value indicates that there are different elements for the page 'private' and 'public' content
or that the elements themselves have changed.

=cut
