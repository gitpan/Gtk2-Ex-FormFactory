package Gtk2::Ex::FormFactory::Label;

use strict;

use base qw( Gtk2::Ex::FormFactory::Widget );

sub get_type  { "label" }
sub has_label { shift->get_object eq '' }

sub get_with_markup		{ shift->{with_markup}			}
sub set_with_markup		{ shift->{with_markup}		= $_[1]	}

sub new {
	my $class = shift;
	my %par = @_;
	my ($with_markup) = $par{'with_markup'};

	my $self = $class->SUPER::new(@_);
	
	$self->set_with_markup($with_markup);
	
	return $self;
}

sub object_to_widget {
	my $self = shift;

	if ( $self->get_with_markup ) {
		$self->get_gtk_widget->set_markup($self->get_object_value);
	} else {
		$self->get_gtk_widget->set_text($self->get_object_value);
	}

	1;
}

sub empty_widget {
	my $self = shift;
	
	$self->get_gtk_widget->set_text("");
	
	1;
}

1;

__END__

=head1 NAME

Gtk2::Ex::FormFactory::Label - A Label in a FormFactory framework

=head1 SYNOPSIS

  Gtk2::Ex::FormFactory::Label->new (
    with_markup => Should the label render with markup?
    ...
    Gtk2::Ex::FormFactory::Widget attributes
  );

=head1 DESCRIPTION

This class implements a Label in a Gtk2::Ex::FormFactory framework.
The text of the Label is the value of the associated application
object attribute. If no object is associated with the Label, the text
is taken from the standard B<label> attribute.

=head1 OBJECT HIERARCHY

  Gtk2::Ex::FormFactory::Intro

  Gtk2::Ex::FormFactory::Widget
  +--- Gtk2::Ex::FormFactory::Label

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

=item B<with_markup> = BOOL [optional]

If this is set to TRUE the Label may contain basic HTML markup,
which is rendered accordingly. Refer to the "Pango Text Attribute Markup"
chapter in the Gtk+ documentation for details.

=back

For more attributes refer to L<Gtk2::Ex::FormFactory::Widget>.

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