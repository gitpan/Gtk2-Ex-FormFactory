package Gtk2::Ex::FormFactory::ToggleButton;

use strict;

use base qw( Gtk2::Ex::FormFactory::Widget );

sub get_type { "toggle_button" }

sub get_true_label		{ shift->{true_label}	|| "Yes"	}
sub get_false_label		{ shift->{false_label}	|| "No"		}

sub set_true_label		{ shift->{true_label}		= $_[1]	}
sub set_false_label		{ shift->{false_label}		= $_[1]	}

sub new {
	my $class = shift;
	my %par = @_;
	my ($true_label, $false_label) = @par{'true_label','false_label'};

	my $self = $class->SUPER::new(@_);
	
	$self->set_true_label($true_label);
	$self->set_false_label($false_label);
	
	return $self;
}

sub object_to_widget {
	my $self = shift;

	$self->get_gtk_widget->set_active($self->get_object_value);

	$self->update_button_label;

	1;
}

sub widget_to_object {
	my $self = shift;
	
	$self->set_object_value ($self->get_gtk_widget->get_active ? 1 : 0);
	
	1;
}

sub backup_widget_value {
	my $self = shift;
	
	$self->set_backup_widget_value ($self->get_gtk_widget->get_active ? 1 : 0);
	
	1;
}

sub restore_widget_value {
	my $self = shift;
	
	$self->get_gtk_widget->set_active($self->get_backup_widget_value);
	
	1;
}

sub get_widget_check_value {
	$_[0]->get_gtk_widget->get_active;
}

sub connect_changed_signal {
	my $self = shift;
	
	$self->get_gtk_widget->signal_connect (
	  toggled => sub {
	  	$self->update_button_label;
	  	$self->widget_value_changed;
	  },
	);
	
	1;
}

sub update_button_label {
	my $self = shift;
	
	my $value      = $self->get_gtk_widget->get_active;
	my $gtk_widget = $self->get_gtk_widget;

	if ( $value ) {
		$gtk_widget->set_label($self->get_true_label);
	} else {
		$gtk_widget->set_label($self->get_false_label);
	}

	1;
}

1;

__END__

=head1 NAME

Gtk2::Ex::FormFactory::ToggleButton - A ToggleButton in a FormFactory framework

=head1 SYNOPSIS

  Gtk2::Ex::FormFactory::ToggleButton->new (
    true_label  => Label of the activated button,
    false_label => Label of the deactivated button,
    ...
    Gtk2::Ex::FormFactory::Widget attributes
  );

=head1 DESCRIPTION

This class implements a ToggleButton in a Gtk2::Ex::FormFactory framework.
The state of the ToggleButton is controlled by the associated application
object attribute, which should has a boolean value.

=head1 OBJECT HIERARCHY

  Gtk2::Ex::FormFactory::Intro

  Gtk2::Ex::FormFactory::Widget
  +--- Gtk2::Ex::FormFactory::ToggleButton

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

=item B<true_label> = SCALAR [optional]

Once the button is activated this label is set.

=item B<false_label> = SCALAR [optional]

Once the button is deactivated this label is set.

=back

For more attributes refer to L<Gtk2::Ex::FormFactory::Widget>.

=head1 AUTHORS

 J�rn Reder <joern at zyn dot de>

=head1 COPYRIGHT AND LICENSE

Copyright 2004-2005 by J�rn Reder.

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
