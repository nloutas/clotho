package Clotho::Element::RSSitem;
use base 'Clotho::Element';  # SUPERCLASS
use strict;

sub new {
  my $pkg = shift;
  my $obj = $pkg->SUPER::new(@_);
  return bless $obj,$pkg;
}

sub default_templateid { return 2; }

sub fields {
    my $self = shift;
    $self->{'fields'} = [
     { name => 'LINK', mandatory => 1, title => 'Link', hint => '', fieldType => 'text', length => 50},
     { name => 'DESCRIPTION', mandatory => 1, title => 'Description', hint => 'RSS item description', fieldType => 'textarea', length => 10 }, 
     { name => 'PUBDATE', mandatory => 0, title => 'Publication Date', hint => '', fieldType => 'date', length => 20 },
     { name => 'GUID', mandatory => 1, title => 'GUID Link', hint => '', fieldType => 'text', length => 50},
    ];
}

sub as_string {
    my $self = shift;
    my $text = join "\n", $self->name, $self->{content}->{LINK}, $self->{content}->{DESCRIPTION}, $self->{content}->{PUBDATE}, $self->{content}->{GUID};
    return $self->strip_html($text);
}

1;
__END__
