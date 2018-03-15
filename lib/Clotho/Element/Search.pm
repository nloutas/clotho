package Clotho::Element::Search;
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
     { name => 'ROOT', mandatory => 1, title => 'Search Root URL', hint => 'URL for the Root page of the Search', fieldType => 'text', length => 70 }, 
     { name => 'LANGUAGE', mandatory => 1, title => 'Interface language', hint => 'language for the GUI search form; default English', fieldType => 'select', options => ['EN', 'GR'] },
    ];
}

sub as_string {
    my $self = shift;
    my $text = $self->name. "\n" . $self->{content}->{ROOT};
    return $self->strip_html($text);
}

1;
__END__
