package Clotho::Element::Frame;
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
     { name => 'SOURCE', mandatory => 1, title => 'Frame Source URL', hint => 'URL for the source of the Frame', fieldType => 'text', length => 70 }, 
    ];
}

sub as_string {
    my $self = shift;
    my $text = $self->name. "\n" . $self->{content}->{SRC};
    return $self->strip_html($text);
}

1;
__END__
