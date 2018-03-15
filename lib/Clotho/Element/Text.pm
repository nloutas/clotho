package Clotho::Element::Text;
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
     { name => 'BODY', mandatory => 1, title => 'Text Body', hint => 'Content for this Element', fieldType => 'textarea', length => 10 }, 
    ];
}

sub as_string {
    my $self = shift;
    my $text = $self->name. "\n" . $self->{content}->{BODY};
    return $self->strip_html($text);
}

1;
__END__
