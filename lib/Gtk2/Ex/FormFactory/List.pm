package Gtk2::Ex::FormFactory::List;

use strict;
use Carp;

use base qw( Gtk2::Ex::FormFactory::Widget );

sub get_type { "list" }

sub get_attr_select		{ shift->{attr_select}			}
sub get_columns			{ shift->{columns}			}
sub get_types			{ shift->{types}			}
sub get_editable		{ shift->{editable}			}
sub get_selection_mode		{ shift->{selection_mode}		}
sub get_is_editable		{ shift->{is_editable}			}
sub get_selection_backup	{ shift->{selection_backup}		}

sub set_attr_select		{ shift->{attr_select}		= $_[1]	}
sub set_columns			{ shift->{columns}		= $_[1]	}
sub set_types			{ shift->{types}		= $_[1]	}
sub set_editable		{ shift->{editable}		= $_[1]	}
sub set_selection_mode		{ shift->{selection_mode}	= $_[1]	}
sub set_is_editable		{ shift->{is_editable}		= $_[1]	}
sub set_selection_backup	{ shift->{selection_backup}	= $_[1]	}

sub has_additional_attrs	{ [ "select" ] 				}

sub new {
	my $class = shift;
	my %par = @_;
	my  ($attr_select, $columns, $types, $editable, $selection_mode, ) =
	@par{'attr_select','columns','types','editable','selection_mode'};

	croak "'columns' attribute is mandatory" unless $columns;

	my $self = $class->SUPER::new(@_);
	
	$attr_select =~ s/^[^.]+\.//;
	
	$self->set_attr_select	  ($attr_select);
	$self->set_columns  	  ($columns);
	$self->set_types    	  ($types);
	$self->set_editable 	  ($editable);
	$self->set_selection_mode ($selection_mode);

	my $is_editable = 0;
	map { $is_editable = 1 if $_ } @{$editable};
	
	$self->set_is_editable($is_editable);
	
	return $self;
}

sub object_to_widget {
	my $self = shift;

	$self->get_gtk_widget->set_data_array($self->get_object_value);

	if ( $self->get_attr_select ) {
		my $idx = $self->get_proxy->get_attr (
			$self->get_attr_select
		);
		$self->get_gtk_widget->select(@{$idx});
	}

	1;
}

sub widget_to_object {
	my $self = shift;
	
	if ( $self->get_is_editable ) {
		my $data = $self->get_gtk_widget->{data};
		my @value = @{$data};
		$self->set_object_value (\@value);
	}
	
	if ( $self->get_attr_select ) {
		my @sel = $self->get_gtk_widget->get_selected_indices;
		$self->get_proxy->set_attr (
			$self->get_attr_select, \@sel
		); 
	}

	1;
}

sub empty_widget {
	my $self = shift;

	$self->get_gtk_widget->set_data_array([]);
	$self->get_gtk_widget->get_selection->unselect_all;

	1;
}

sub backup_widget_value {
	my $self = shift;

	if ( $self->get_is_editable ) {
		my $data = $self->get_gtk_widget->{data};
		my @value = @{$data};
		$self->set_backup_widget_value (\@value);
	}
	
	if ( $self->get_attr_select ) {
		my @sel = $self->get_gtk_widget->get_selected_indices;
		$self->set_selection_backup(\@sel);
	}

	1;
}

sub restore_widget_value {
	my $self = shift;

	if ( $self->get_is_editable ) {
		$self->get_gtk_widget
		     ->set_data_array($self->get_backup_widget_value);
	}

	if ( $self->get_attr_select ) {
		my $idx = $self->get_selection_backup;
		$self->get_gtk_widget->select(@{$idx});
	}

	1;
}

sub get_widget_check_value {
	$_[0]->get_gtk_widget->{data};
}

sub connect_changed_signal {
	my $self = shift;
	
	if ( $self->get_is_editable ) {
		$self->get_gtk_widget->get_model->signal_connect (
		  'row-changed' => sub { $self->widget_value_changed },
		);
	}
	
	if ( $self->get_attr_select ) {
		$self->get_gtk_widget->get_selection->signal_connect (
		  'changed'	=> sub { $self->widget_value_changed },
		);
	}
	

	1;
}

1;

__END__

=head1 NAME

Gtk2::Ex::FormFactory::List - A List in a FormFactory framework

=head1 SYNOPSIS

  Gtk2::Ex::FormFactory::List->new (
    attr_select    => Attribute name for selection tracking,
    columns        => Titles of the list columns,
    types          => Types of the list columns,
    editable       => Is content editable?,
    selection_mode => Selection mode of this list,
    ...
    Gtk2::Ex::FormFactory::Widget attributes
  );

=head1 DESCRIPTION

This class implements a List in a Gtk2::Ex::FormFactory framework
(based on Gtk2::Ex::Simple::List). The value of the associated
application object attribute needs to be a reference to a two
dimensional array with the content of the list.

=head1 OBJECT HIERARCHY

  Gtk2::Ex::FormFactory::Intro

  Gtk2::Ex::FormFactory::Widget
  +--- Gtk2::Ex::FormFactory::List

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

=item B<attr_select> = SCALAR [optional]

If you want to track the selection state of the List set the name
of the attribute of the associated application object here. A
array reference with the indicies of the selected rows will be
managed automatically and stored in this attribute.

=item B<columns> = ARRAYREF [mandatory]

This is a reference to an array containing the column titles
of this list.

=item B<types> = ARRAYREF [optional]

You may define types for the columns of the list. The type of a column
defaults to 'text'. Other possible types are:

  text    normal text strings
  markup  pango markup strings
  int     integer values
  double  double-precision floating point values
  bool    boolean values, displayed as toggle-able checkboxes
  scalar  a perl scalar, displayed as a text string by default
  pixbuf  a Gtk2::Gdk::Pixbuf

=item B<editable> = BOOL [optional]

If you set this to TRUE the contents of your list can be
edited inplace. Changes are synchronized automatically with
the associated application object attribute.

=item B<selection_mode> = 'none'|'single'|'browse'|'multiple' [optional]

You may specify a selection mode for the list. Please refer to
the Gtk+ documentation of GtkSelectionMode for details about
the possible selection modes.

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
