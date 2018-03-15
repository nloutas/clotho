package Clotho::Element::Article;
use base 'Clotho::Element';
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
     { name => 'AUTHOR' =>  mandatory => 1, title => 'Author', hint => '', fieldType => 'text', length => 50},
     { name => 'DATE', mandatory => 0, title => 'Date', hint => '', fieldType => 'date', length => 20 },
     { name => 'ABSTRACT', mandatory => 0, title => 'Abstract', hint => 'Short Abstract for this Article', fieldType => 'textarea', length => 3 },
     { name => 'BODY', mandatory => 1, title => 'Article Body', hint => 'Full Content for this Article', fieldType => 'textarea', length => 10 },
     { name => 'KEYWORDS', mandatory => 0, title => 'Keywords', hint => '', fieldType => 'text', length => 100 },
     { name => 'COMMENT', mandatory => 0, title => 'Comment', hint => '', fieldType => 'text', length => 100},
    ];
}

sub as_string {
    my $self = shift;
    my $text = $self->name. "\nAuthor: ". $self->{content}->{AUTHOR} . "\n" . $self->{content}->{BODY};
    return $self->strip_html($text);
}

1;
__END__
