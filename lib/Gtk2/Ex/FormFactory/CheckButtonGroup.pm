package Gtk2::Ex::FormFactory::CheckButtonGroup;

use Carp;
use strict;

use base qw( Gtk2::Ex::FormFactory::Widget );
use POSIX qw(ceil);

sub get_type { "check_button_group" }

sub get_max_columns		{ shift->{max_columns}			}
sub get_max_rows		{ shift->{max_rows}			}

sub set_max_columns		{ shift->{max_columns}		= $_[1]	}
sub set_max_rows		{ shift->{max_rows}		= $_[1]	}

sub get_gtk_check_buttons	{ shift->{gtk_check_buttons}		}
sub set_gtk_check_buttons	{ shift->{gtk_check_buttons}	= $_[1]	}

sub new {
	my $class = shift;
	my %par = @_;
	my ($max_columns, $max_rows) = @par{'max_columns','max_rows'};

	croak "Set max_columns OR max_rows" if $max_columns && $max_rows;

	my $self = $class->SUPER::new(@_);

	$max_rows = 1 if $max_rows == 0 and $max_columns == 0;
	
	$self->set_max_columns($max_columns);
	$self->set_max_rows($max_rows);
	
	return $self;
}

sub cleanup {
	my $self = shift;
	
	$self->SUPER::cleanup(@_);
	
	$self->set_gtk_check_buttons(undef);

	1;
}

sub object_to_widget {
	my $self = shift;
	
	#-- $checkboxes = [ [0, "Sun"], [1 ,"Mon"], [2,"Tue"], ... ]
	my $checkboxes    = $self->get_proxy->get_attr_list(
		$self->get_attr, $self->get_name
	);

	#-- $selected_href = { 0 => 1, 2 => 1 }  - Sun and Tue are selected
	my $selected_href = $self->get_object_value;
	
	my $hbox = $self->get_gtk_widget;
	my @children = $hbox->get_children;
	$hbox->remove($_) for @children;

	my ($rows, $columns);
	my $max_rows    = $self->get_max_rows;
	my $max_columns = $self->get_max_columns;
	my $cnt = @{$checkboxes};

	if ( $max_rows ) {
		$rows = $max_rows;
		$rows = $cnt if $rows > $cnt;
		$columns = ceil($cnt / $rows);
	} else {
		$columns = $max_columns;
		$columns = $cnt if $columns > $cnt;
		$rows = ceil($cnt / $columns);
	}

	my %gtk_check_buttons;
	my $gtk_table = Gtk2::Table->new ($rows, $columns);
	$gtk_table->set ( homogeneous => 1 );
	my $i = 0;
	for ( my $c=0; $c < $columns && $i < $cnt; ++$c ) {
		for ( my $r=0; $r < $rows && $i < $cnt; ++$r ) {
			my $checkbox = $checkboxes->[$i];
			my $gtk_check_button = Gtk2::CheckButton->new($checkbox->[1]);
			$gtk_check_buttons{$checkbox->[0]} = $gtk_check_button;
			$gtk_check_button->set_active(1) if $selected_href->{$checkbox->[0]};
			$gtk_table->attach_defaults($gtk_check_button, $c, $c+1, $r, $r+1);
			++$i;
		}
	}

	$hbox->pack_start($gtk_table, 0, 1, 0);
	$hbox->show_all;

	$self->set_gtk_check_buttons(\%gtk_check_buttons);

	1;
}

sub widget_to_object {
	my $self = shift;
	
	my $gtk_check_buttons = $self->get_gtk_check_buttons;
	my %selected;
	
	while ( my ($value, $gtk_check_button) = each %{$gtk_check_buttons} ) {
		$selected{$value} = 1 if $gtk_check_button->get_active;
	}
	
	$self->set_object_value(\%selected);
	
	1;
}

sub backup_widget_value {
	my $self = shift;
	
	
	1;
}

sub restore_widget_value {
	my $self = shift;
	
	
	1;
}

sub get_widget_check_value {
#	$_[0]->get_gtk_yes_widget->get_active;
}

sub connect_changed_signal {
	my $self = shift;
	
#	$self->get_gtk_yes_widget->signal_connect (
#	  toggled => sub { $self->widget_value_changed },
#	);
	
	1;
}

1;

__END__

=head1 NAME

Gtk2::Ex::FormFactory::CheckButtonGroup - A group of checkbuttons

=head1 SYNOPSIS

  Gtk2::Ex::FormFactory::CheckButtonGroup->new (
    max_columns => Maximum number of columns,
    max_rows    => Maximum number of rows,
    ...
    Gtk2::Ex::FormFactory::Widget attributes
  );

=head1 DESCRIPTION

This class implements a group of check buttons which allow
a multiple selection out of a set from predefined values.
It's arranged in a two dimensional table. You can specify
either the maximum number of rows or columns, the actual
dimensions are calculated automatically.

The value of a CheckBoxGroup is a hash. The value of each
selected checkbox will result in a correspondent hash key
with a true value assigned.

=head1 OBJECT HIERARCHY

  Gtk2::Ex::FormFactory::Intro

  Gtk2::Ex::FormFactory::Widget
  +--- Gtk2::Ex::FormFactory::CheckButtonGroup

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

=item B<max_columns> = SCALAR [optional]

Maximum number of columns the table should have. You must not set
B<max_rows> when you specify B<max_columns>.

=item B<max_rows> = SCALAR [optional]

Maximum number of rows the table should have. You must not set
B<max_columns> when you specify B<max_rows>. If you omit both
attributes B<max_rows> defaults to 1, so all buttons will appear
in one row.

=back

=head1 REQUIREMENTS FOR ASSOCIATED APPLICATION OBJECTS

Application objects represented by a Gtk2::Ex::FormFactory::CheckButtonGroup
must define additional methods. The naming of the methods listed
beyond uses the standard B<get_> prefix for the attribute read
accessor. B<ATTR> needs to be replaced by the actual name of
the attribute associated with the widget.

=over 4

=item B<get_ATTR_list>

This method must return a two dimensional array resp. a list 
of lists which represent the values the user can select from.

Example:

  [
    [ 0, "Sun" ],
    [ 1, "Mon" ],
    [ 2, "Tue" ],
    ...
  ]

Each entry in the list consists of a list ref with two elements.
The first is the value associated with the checkbox (which will
become a hash key in the associated object attribute), the second
the label of the checkbox on the GUI.

=back

For more attributes refer to L<Gtk2::Ex::FormFactory::Widget>.

=head1 AUTHORS

 Jörn Reder <joern at zyn dot de>

=head1 COPYRIGHT AND LICENSE

Copyright 2004 by Jörn Reder.

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
