package Gtk2::Ex::FormFactory::Container;

use strict;

use base qw( Gtk2::Ex::FormFactory::Widget );

sub get_content			{ shift->{content}			}
sub get_title			{ shift->{title}			}

sub set_content			{ shift->{content}		= $_[1]	}
sub set_title			{ shift->{title}		= $_[1]	}

sub isa_container		{ 1 }

sub new {
	my $class = shift;
	my %par = @_;
	my ($content, $title) = @par{'content','title'};
	
	my $self = $class->SUPER::new(@_);

	#-- Handle some defaults for 'content' parameter
	if ( not defined $content ) {
		$content = [];
	} elsif ( ref $content ne 'ARRAY' ) {
		$content = [ $content ];
	}
	
	#-- For convenience the developer may write pairs of
	#-- the Widget's short name and a hash ref with its
	#-- attributes instead of adding real objects. This
	#-- loop search for such non-objects and creates
	#-- objects accordingly.
	my @content_with_objects;
	for ( my $i=0; $i < @{$content}; ++$i ) {
		if ( not ref $content->[$i] ) {
			#-- No object, so derive the class name
			#-- from the short name
			my $class = $content->[$i];
			$class =~ s/^(.)/uc($1)/e;
			$class =~ s/_(.)/uc($1)/eg;
			$class =~ s/_//g;
			$class = "Gtk2::Ex::FormFactory::$class";
			
			#-- And create the object
			my $object = $class->new(%{$content->[$i+1]});
			push @content_with_objects, $object;
			
			#-- Skip next entry in @content
			++$i;

		} else {
			#-- Regular objects are taken as is
			push @content_with_objects, $content->[$i];
		}
	}
	
	$self->set_content(\@content_with_objects);
	$self->set_title($title);

	return $self;
}

sub build {
	my $self = shift;

	#-- First build the widget itself
	$self->SUPER::build(@_);
	
	#-- Now build the children
	$self->build_children;

	1;
}

sub build_children {
	my $self = shift;
	
	$Gtk2::Ex::FormFactory::DEBUG &&
		print "$self->build_children\n";

	my $layouter = $self->get_form_factory->get_layouter;

	foreach my $child ( @{$self->get_content} ) {
		$child->set_parent($self);
		$child->set_form_factory($self->get_form_factory);
		$child->build;
		$layouter->add_widget_to_container ($child, $self);
	}
	
	1;	
}

sub update_all {
	my $self = shift;
	
	$self->SUPER::update(@_);
	$_->update_all for @{$self->get_content};
	
	1;
}

sub apply_changes_all {
	my $self = shift;
	
	$self->SUPER::apply_changes(@_);
	$_->apply_changes for @{$self->get_content};
	
	1;
}

sub connect_signals {
	my $self = shift;
	
	$self->SUPER::connect_signals(@_);
	$_->connect_signals for @{$self->get_content};
	
	1;
}

sub cleanup {
	my $self = shift;
	
	$_->cleanup for @{$self->get_content};
	$self->SUPER::cleanup(@_);

	$self->set_content(undef);

	1;
}

1;

__END__

=head1 NAME

Gtk2::Ex::FormFactory::Container - A container in a FormFactory framework

=head1 SYNOPSIS

  Gtk2::Ex::FormFactory::Container->new (
    title      => Visible title of this container,
    content    => [ List of children ],
    ...
    Gtk2::Ex::FormFactory::Widget attributes
  );

=head1 DESCRIPTION

This is an abstract base class for all containers in the
Gtk2::Ex::FormFactory framework.

=head1 OBJECT HIERARCHY

  Gtk2::Ex::FormFactory::Intro

  Gtk2::Ex::FormFactory::Widget
  +--- Gtk2::Ex::FormFactory::Container
       +--- Gtk2::Ex::FormFactory::Buttons
       +--- Gtk2::Ex::FormFactory::Expander
       +--- Gtk2::Ex::FormFactory::Form
       +--- Gtk2::Ex::FormFactory::HBox
       +--- Gtk2::Ex::FormFactory::Notebook
       +--- Gtk2::Ex::FormFactory::Table
       +--- Gtk2::Ex::FormFactory::VBox
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

=item B<title> = SCALAR [optional]

Each container may have a title. How this title actually is rendered
depends on the implementation of a particular container resp.
the implementation of this container in Gtk2::Ex::FormFactory::Layout.
Default is to draw a frame with this title around the container
widget.

=item B<content> = ARRAYREF of Gtk2::Ex::FormFactory::Widget's [optional]

This is a reference to an array containing the children of this container.

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
