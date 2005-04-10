package Gtk2::Ex::FormFactory::Window;

use strict;

use base qw( Gtk2::Ex::FormFactory::Container );

sub get_type { "window" }

sub get_closed_hook		{ shift->{closed_hook}			}
sub set_closed_hook		{ shift->{closed_hook}		= $_[1]	}

sub new {
	my $class = shift;
	my %par = @_;
	my ($closed_hook) = $par{'closed_hook'};

	my $self = $class->SUPER::new(@_);
	
	$self->set_closed_hook($closed_hook);
	
	return $self;
}

1;

__END__

=head1 NAME

Gtk2::Ex::FormFactory::Window - A Window in a FormFactory framework

=head1 SYNOPSIS

  Gtk2::Ex::FormFactory::Window->new (
    closed_hook => Code reference to be called on window close,
    ...
    Gtk2::Ex::FormFactory::Container attributes
    Gtk2::Ex::FormFactory::Widget attributes
  );

=head1 DESCRIPTION

This class implements a Window in a Gtk2::Ex::FormFactory framework.
No application object attributes are associated with a Window.

By default a Window automatically is implemented with an VBox. So
you can add more than one widget to a Gtk2::Ex::FormFactory::Window
in contrast to a Gtk2::Window.

Note: if a window has a Gtk2::Ex::FormFactory parent, the FormFactory
is closed automatically when the window gets destroyed.

=head1 OBJECT HIERARCHY

  Gtk2::Ex::FormFactory::Intro

  Gtk2::Ex::FormFactory::Widget
  +--- Gtk2::Ex::FormFactory::Container
       +--- Gtk2::Ex::FormFactory::Window

  Gtk2::Ex::FormFactory::Layout
  Gtk2::Ex::FormFactory::Rules
  Gtk2::Ex::FormFactory::Context
  Gtk2::Ex::FormFactory::Proxy

=head1 ATTRIBUTES

Attributes are handled through the common get_ATTR(), set_ATTR()
style accessors, but they are mostly passed once to the object
constructor and must not be altered after the associated FormFactory
was built.

=over 4

=item B<closed_hook> = CODEREF [optional]

This code reference is called, when the window gets destroyed, e.g.
because the user closes the window using the window manager's close
button, or the program calls GtkWindow->destroy directly.

=back

=head1 AUTHORS

 J�rn Reder <joern at zyn dot de>

=head1 COPYRIGHT AND LICENSE

Copyright 2004 by J�rn Reder.

This library is free software; you can redistribute it and/or modify
it under the terms of the GNU Library General Public License as
published by the Free Software Foundation; either version 2.1 of the
License, or (at your option) any later version.

This library is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Library General Public License for more details.

You should have received a copy of the GNU Library General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307
USA.

=cut