package Clotho::Search;
use strict;

use Data::Dumper;

sub new {
    my $pkg  = shift;
    my $obj  = { @_, 'hits' => 0 };
    bless $obj, $pkg;

    if ($obj->id){
       $obj->getSearchById($obj->id);
    }
    elsif ($obj->keyword) {
       $obj->getSearchByKeyword($obj->keyword);
    }

    return $obj;
}

###############################################################
# ACCESSOR METHODS
###############################################################
sub id {
    my $self = shift;
    @_ ? $self->{'id'} = shift : return $self->{'id'};
}

sub hits {
    my $self = shift;
    @_ ? $self->{'hits'} = shift : return $self->{'hits'};
}

sub pageHits {
    my $self = shift;
    @_ ? $self->{'pageHits'} = shift : return $self->{'pageHits'};
}

sub endPage {
    my $self = shift;
    return ($self->hits / $::request->{'hitsPerPage'});
}

sub keyword {
    my $self = shift;
    @_ ? $self->{'keyword'} = shift : return $self->{'keyword'};
}

sub results {
    my $self = shift;
    @_ ? $self->{'results'} = shift : return $self->{'results'};
}

sub root {
    my $self = shift;
    @_ ? $self->{'root'} = shift : return $self->{'root'};
}

###############################################################
# CORE METHODS
###############################################################
sub pPageLink {
    my $self = shift;
    return unless ($::request->{'pageno'} > 1);
    return qq{<a href="?view=admin&template=adminSite&searchid=$::request->{'searchid'}&pageno=}. ($::request->{'pageno'} -1) .qq{" class="searchResult">&lt;&lt; &nbsp;}.$::request->translate('Previous') .q{</a>};
}

sub nPageLink {
    my $self = shift;
    return unless ($::request->pageno  < $self->endPage);
    return qq{<a href="?view=admin&template=adminSite&searchid=$::request->{'searchid'}&pageno=}. ($::request->{'pageno'}+1) .qq{" class="searchResult">&nbsp; }.$::request->translate('Next') .q{ &gt;&gt;</a>};
}

sub displayResults {
    my $self = shift;
    my @results = ();
    foreach (split ',', $self->results){
       push @results, new Clotho::Page(id=>$_);
    }
    return @results;
}

############################################################################
# DB methods
############################################################################
sub getSearchById {
   my $self = shift;
   my $id = shift || $self->id;
   return unless $id;
   $::dbquery{'getSearchById'} ||= $::dbh->prepare(qq{SELECT id, 
   hits, keyword, results,
   DATE_FORMAT(updatedate, '%d/%m/%Y') as updatedate
   FROM search WHERE id = ?
      }); 
   $::dbquery{'getSearchById'}->execute($id);

   my $results= {};
   $results = $::dbquery{'getSearchById'}->fetchrow_hashref
	     unless ($::dbquery{'getSearchById'}->err);
#::syslog('error', " getSearchById: $id ". Dumper($results));
   return $results;
}

sub getSearchByKeyword {
   my $self = shift;
   my $keyword = shift;
   return unless $keyword;
   $keyword = '%'.$keyword.'%';
   $::dbquery{'getSearchByKeyword'} ||= $::dbh->prepare(qq{SELECT id, name, 
   statusid, authorid, textcontent, keywords,
   DATE_FORMAT(updatedate, '%d/%m/%Y') as updatedate
   FROM page WHERE deleted = 0 AND path like ? 
   AND (name like ? OR keywords like ? OR textcontent like ?)});
   $::dbquery{'getSearchByKeyword'}->execute($self->root.'%', $keyword, $keyword, $keyword);

   my $results;
   $results = $::dbquery{'getSearchByKeyword'}->fetchall_arrayref( {} )
             unless ($::dbquery{'getSearchByKeyword'}->err);
#::syslog('error', " getSearchByKeyword: $keyword ".(scalar @$results) . Dumper($results));
   return unless $results;
   $self->results(join ',', map {$_->{'id'}} @$results);
   $self->hits(1+$#{@$results});
   my $id = $self->insert();

}

sub insert {
   my $self = shift;

   $::dbquery{'insert_search'} ||= $::dbh->prepare(qq{INSERT INTO search VALUES(NULL,?,?,?,now())});

   my $newid ;
   unless ($newid = $::dbquery{'insert_search'}->execute($self->keyword, $self->hits, $self->results)) {
      ::syslog('error', 'Unable to insert new search results: '. $::dbh->errstr);
      $::dbh->rollback;
      return;
   }

   return $newid;
}

sub update {
   my $self = shift;
   my %val  = @_;
   return unless (%val);
   my $id   = $self->id;
   my $sql = 'UPDATE search SET updatedate = now()';
   foreach (keys %val){
      $sql .= ", $_ = '$val{$_}'";
   }
   $sql .= " WHERE id = $id";

   my $result;
   $result = $::dbh->do("$sql", undef) 
      or ::syslog('error', "Unable to update search '$id': ". $::dbh->errstr);

   return $result;
}

sub delete {
   my $self = shift;
   my $id = shift || $self->id;
   my $result;
   $result = $::dbh->do("DELETE FROM search WHERE id = ?", undef, $id) 
      or ::syslog('error', "Unable to delete search '$id': ". $::dbh->errstr);

   return $result;
}

1;
__END__

=item Clotho::Search->new(%args)

Returns a Search object with any additional attributes specified in I<%args>,
plus the data returned by an immediate call to the I<get_search_details> method.
Normally, a new search is created with a I<id> or I<path> by which it can be identified.


=item $search->id([$value])

When called without any arguments, returns a scalar value which uniquely
identifies the search to the storage backend. If called with an argument, sets the
value of the search's id to I<$value>.

=item $search->c

=cut
