package Clotho::Element::Navigation;
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
     { name => 'MENUS', mandatory => 1, title => 'Navigation Menus', hint => 'Enter one line for each menu item or submenu', fieldType => 'textarea', length => 10, 'default' => 'addItem("Home","/");' },
     { name => 'ALIGN', mandatory => 1, title => 'Nav Bar Alignment', hint => 'Align this Navigation bar on the horizontal or vertical axis', fieldType => 'select', options => ['horizontal', 'vertical'] },
     { name => 'WIDTH', mandatory => 0, title => 'Nav Bar Width', hint => 'The pixel width for the Navigation items (defaults; vertical=100, horizontal=17)', fieldType => 'text', length => 10, 'default' => 17 },
    ];
}

sub menus {
    my $self = shift;
    my @menus = (split "\n", $self->{'content'}->{'MENUS'});
    use Data::Dumper;
#::syslog('error', "Element menus ".$self->{'content'}->{'MENUS'});
    return @menus;
}

sub as_string {
    my $self = shift;
    my $text = $self->name. "\n" . $self->{content}->{ALIGN};
    return $self->strip_html($text);
}

1;
__END__
