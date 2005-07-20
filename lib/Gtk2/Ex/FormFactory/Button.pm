package Gtk2::Ex::FormFactory::Button;

use strict;

use base qw( Gtk2::Ex::FormFactory::Widget );

sub get_type 	{ "button" 	}
sub has_label	{ 1		}

sub get_clicked_hook		{ shift->{clicked_hook}			}
sub get_stock			{ shift->{stock}			}

sub set_clicked_hook		{ shift->{clicked_hook}		= $_[1]	}
sub set_stock			{ shift->{stock}		= $_[1]	}

sub new {
	my $class = shift;
	my %par = @_;
	my ($stock, $clicked_hook) = @par{'stock','clicked_hook'};

	my $self = $class->SUPER::new(@_);

	$self->set_stock($stock);
	$self->set_clicked_hook($clicked_hook);
	
	return $self;
}

1;

__END__

=head1 NAME

Gtk2::Ex::FormFactory::Button - A Button in a FormFactory framework

=head1 SYNOPSIS

  Gtk2::Ex::FormFactory::Button->new (
    clicked_hook => Callback CODEREF / Closure
    stock        => Name of a stock item for this button,
    ...
    Gtk2::Ex::FormFactory::Widget attributes
  );

=head1 DESCRIPTION

This module implements a Button in a Gtk2::Ex::FormFactory framework.
No application object attribute is associated with the button.

=head1 OBJECT HIERARCHY

  Gtk2::Ex::FormFactory::Intro

  Gtk2::Ex::FormFactory::Widget
  +--- Gtk2::Ex::FormFactory::Button

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

=item B<clicked_hook> = CODEREF [optional]

This is for convenience and connects the CODEREF to the clicked
signal of the button.

=item B<stock> = SCALAR [optional]

You may specify the name of a stock item here, which should be
added to the button, e.g. 'gtk-edit' for the standard Gtk Edit
stock item. You may combine B<stock> and B<label> arbitrarily.

=back

For more attributes refer to L<Gtk2::Ex::FormFactory::Widget>.

=head1 AUTHORS

 Jörn Reder <joern at zyn dot de>

=head1 COPYRIGHT AND LICENSE

Copyright 2004-2005 by Jörn Reder.

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
