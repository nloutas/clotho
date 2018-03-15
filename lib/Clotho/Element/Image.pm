package Clotho::Element::Image;
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
     { name => 'SRC' =>  mandatory => 1, title => 'Image Source URL', hint => 'URL or relative path for the SRC of this Image', fieldType => 'text', length => 50 },
     { name => 'ALT', mandatory => 0, title => 'Image Alternative Text', hint => 'Alt Text for this Image', fieldType => 'text', length => 100 },
     { name => 'BORDER', mandatory => 0, title => 'Image Border', hint => 'Border size number for this Image; default 0', fieldType => 'text', length => 3 },
     { name => 'ALIGN', mandatory => 0, title => 'Image Alignment', hint => 'Align this Image on the horizontal or vertical axis', fieldType => 'select', options => ['bottom', 'middle', 'top', 'left', 'right'] },
     { name => 'HSPACE', mandatory => 0, title => 'Image Horizontal Space', hint => 'HSPACE number for this Image; default 0', fieldType => 'text', length => 3 },
     { name => 'VSPACE', mandatory => 0, title => 'Image Vertical Space', hint => 'VSPACE number for this Image; default 0', fieldType => 'text', length => 3 },
     { name => 'WIDTH', mandatory => 0, title => 'Image Width', hint => 'WIDTH size for this Image; leave blank for default width', fieldType => 'text', length => 3 },
     { name => 'HEIGTH', mandatory => 0, title => 'Image Heigth', hint => 'HEIGTH size for this Image; leave blank for default heigth', fieldType => 'text', length => 3 },
    ];
}

sub as_string {
    my $self = shift;
    my $text = $self->{content}->{ALT};
    return $self->strip_html($text);
}

1;
__END__
