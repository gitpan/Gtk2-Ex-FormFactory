package Gtk2::Ex::FormFactory::Combo;

use strict;

use base qw( Gtk2::Ex::FormFactory::Widget );

sub get_type { "combo" }

sub object_to_widget {
	my $self = shift;

	my $gtk_combo = $self->get_gtk_widget;
	my $presets   = $self->get_proxy->get_attr_presets($self->get_attr, $self->get_name);

	$gtk_combo->set_popdown_strings(@{$presets})
		if ref $presets eq 'ARRAY';
	
	$gtk_combo->entry->set_text($self->get_object_value);

	1;
}

sub widget_to_object {
	my $self = shift;
	
	$self->set_object_value ($self->get_gtk_widget->entry->get_text);
	
	1;
}

sub empty_widget {
	my $self = shift;
	
	$self->get_gtk_widget->entry->set_text("");
	
	1;
}

sub backup_widget_value {
	my $self = shift;
	
	$self->set_backup_widget_value ($self->get_gtk_widget->entry->get_text);
	
	1;
}

sub restore_widget_value {
	my $self = shift;
	
	$self->get_gtk_widget->entry->set_text($self->get_object_value);
	
	1;
}

sub get_widget_check_value {
	$_[0]->get_gtk_widget->entry->get_text;
}

sub connect_changed_signal {
	my $self = shift;
	
	$self->get_gtk_widget->entry->signal_connect (
	  changed => sub { $self->widget_value_changed },
	);
	
	1;
}

1;

__END__

=head1 NAME

Gtk2::Ex::FormFactory::Combo - A Combo in a FormFactory framework

=head1 SYNOPSIS

  Gtk2::Ex::FormFactory::Combo->new (
    ...
    Gtk2::Ex::FormFactory::Widget attributes
  );

=head1 DESCRIPTION

This class implements a text entry with a popdown list of presets
in a Gtk2::Ex::FormFactory framework. The content of the entry
is the value of the associated application object attribute.

=head1 OBJECT HIERARCHY

  Gtk2::Ex::FormFactory::Intro

  Gtk2::Ex::FormFactory::Widget
  +--- Gtk2::Ex::FormFactory::Combo

  Gtk2::Ex::FormFactory::Layout
  Gtk2::Ex::FormFactory::Rules
  Gtk2::Ex::FormFactory::Context
  Gtk2::Ex::FormFactory::Proxy

=head1 ATTRIBUTES

This module has no additional attributes over those derived
from Gtk2::Ex::FormFactory::Widget.

=head1 REQUIREMENTS FOR ASSOCIATED APPLICATION OBJECTS

Application objects represented by a Gtk2::Ex::FormFactory::Combo
must define additional methods. The naming of the methods listed
beyond uses the standard B<get_> prefix for the attribute read
accessor. B<ATTR> needs to be replaced by the actual name of
the attribute associated with the widget.

=over 4

=item B<get_ATTR_presets>

This method must return a reference to an array containing the
presets for this Combo box.

=back

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
