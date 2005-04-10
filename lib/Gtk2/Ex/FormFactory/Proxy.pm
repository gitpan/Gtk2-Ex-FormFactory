package Gtk2::Ex::FormFactory::Proxy;

use strict;
use Carp;

my $NAME_CNT = 0;

sub get_context			{ shift->{context}			}
sub get_name			{ shift->{name}				}
sub get_set_prefix		{ shift->{set_prefix}			}
sub get_get_prefix		{ shift->{get_prefix}			}
sub get_attr_activity_href	{ shift->{attr_activity_href}		}
sub get_attr_accessors_href	{ shift->{attr_accessors_href}		}

sub new {
	my $class = shift;
	my %par = @_;
	my  ($context, $object, $name, $set_prefix, $get_prefix) =
	@par{'context','object','name','set_prefix','get_prefix'};
	my  ($attr_accessors_href, $attr_activity_href) =
	@par{'attr_accessors_href','attr_activity_href'};

	$attr_accessors_href ||= {},
	$attr_activity_href  ||= {};
	$name                ||= "object_".$NAME_CNT++; 

	my $self = bless {
		context			=> $context,
		object			=> $object,
		name			=> $name,
		set_prefix		=> $set_prefix,
		get_prefix		=> $get_prefix,
		attr_activity_href	=> $attr_activity_href,
		attr_accessors_href	=> $attr_accessors_href,
	}, $class;
	
	return $self;
}

sub get_object {
	my $self = shift;
	my $object = $self->{object};
	ref $object eq 'CODE' ? &$object() : $object;
}

sub set_object {
	my $self = shift;
	my ($object) = @_;

	$self->{object} = $object;
	
	$self->get_context->update_object_widgets ($self->get_name);

	return $object;
}

sub get_attr {
	my $self = shift;
	my ($attr_name) = @_;
	
	if ( $attr_name =~ /^([^.]+)\.(.*)$/ ) {
		$self      = $self->get_context->get_proxy($1);
		$attr_name = $2;
	}

	my $method   = $self->get_get_prefix.$attr_name;
	my $object   = $self->get_object;
	my $accessor = $self->get_attr_accessors_href->{$method};

	return &$accessor($object) if $accessor;
	return $object->$method();
}

sub set_attr {
	my $self = shift;
	my ($attr_name, $attr_value) = @_;

	if ( $attr_name =~ /^([^.]+)\.(.*)$/ ) {
		$self      = $self->get_context->get_proxy($1);
		$attr_name = $2;
	}

	my $set_prefix = $self->get_set_prefix;
	my $object     = $self->get_object;
	my $name       = $self->get_name;
	my $method     = $set_prefix.$attr_name;
	my $accessor   = $self->get_attr_accessors_href->{$method};
	
	my $rc = $accessor ?
		&$accessor($object, $attr_value) :
		$object->$method($attr_value);
	
	$self->get_context
	     ->update_object_attr_widgets($name, $attr_name, $object);
	
	return $rc;
}

sub set_attrs {
	my $self = shift;
	my ($attrs_href) = @_;
	
	my $set_prefix  = $self->get_set_prefix;
	my $object      = $self->get_object;
	my $name        = $self->get_name;
	my $context     = $self->get_context;
	my $accessors   = $self->get_attr_accessors_href;
	
	my ($method, $attr_name, $attr_value, $accessor);

	while ( ($attr_name, $attr_value) = each %{$attrs_href} ) {
		$method = $set_prefix.$attr_name;
		$accessor = $accessors->{$method};
		$accessor ?
			&$accessor($object, $attr_value) :
			$object->$method($attr_value);
		$context->update_object_attr_widgets(
			$name, $attr_name, $object
		);
	}
	
	1;
}

sub get_attr_presets {
	my $self = shift;
	my ($attr_name) = @_;
	
	my $method  = $self->get_get_prefix.$attr_name."_presets";
	my $object  = $self->get_object;
	my $accessor = $self->get_attr_accessors_href->{$method};

	return &$accessor($object) if $accessor;
	return $object->$method();
}

sub get_attr_rows {
	my $self = shift;
	my ($attr_name) = @_;
	
	my $method  = $self->get_get_prefix.$attr_name."_rows";
	my $object  = $self->get_object;
	my $accessor = $self->get_attr_accessors_href->{$method};

	return &$accessor($object) if $accessor;
	return $object->$method();
}

sub get_attr_list {
	my $self = shift;
	my ($attr_name, $widget_name) = @_;
	
	my $method  = $self->get_get_prefix.$attr_name."_list";
	my $object  = $self->get_object;
	my $accessor = $self->get_attr_accessors_href->{$method};

	return &$accessor($object, $widget_name) if $accessor;
	return $object->$method($widget_name);
}

sub get_attr_presets_static {
	my $self = shift;
	my ($attr_name) = @_;
	
	my $method  = $self->get_get_prefix.$attr_name."_presets_static";
	my $object  = $self->get_object;
	my $accessor = $self->get_attr_accessors_href->{$method};

	return &$accessor($object) if $accessor;
	return 1 if not $object->can($method);
	return $object->$method();
}

sub get_attr_rows_static {
	my $self = shift;
	my ($attr_name) = @_;
	
	my $method  = $self->get_get_prefix.$attr_name."_rows_static";
	my $object  = $self->get_object;
	my $accessor = $self->get_attr_accessors_href->{$method};

	return &$accessor($object) if $accessor;
	return 1 if not $object->can($method);
	return $object->$method();
}

sub get_attr_list_static {
	my $self = shift;
	my ($attr_name) = @_;
	
	my $method  = $self->get_get_prefix.$attr_name."_list_static";
	my $object  = $self->get_object;
	
	return 1 if not $object->can($method);
	return $object->$method();
}

sub get_attr_activity {
	my $self = shift;
	my ($attr_name) = @_;

	my $object = $self->get_object;
	return 0 if not defined $object;

	my $attr_activity_href = $self->get_attr_activity_href;
	return 1 if not exists $attr_activity_href->{$attr_name};

	my $attr_activity = $attr_activity_href->{$attr_name};
	return $attr_activity if not ref $attr_activity eq 'CODE';
	return &$attr_activity($object);
}

1;

__END__

=head1 NAME

Gtk2::Ex::FormFactory::Proxy - Proxy class for application objects

=head1 SYNOPSIS

  #-- Proxies are always created through
  #-- Gtk2::Ex::FormFactory::Context, never
  #-- directly by the application.

  Gtk2::Ex::FormFactory::Proxy->new (
    context              => Gtk2::Ex::FormFactory::Context,
    object               => Object instance or CODEREF,
    name                 => Name of this proxy,
    set_prefix           => Method prefix for write accessors,
    get_prefix           => Method prefix for read accessors,
    attr_accessors_href  => Hashref with accessor callbacks,
    attr_activity_href   => Hashref with activity callbacks,
  );

=head1 DESCRIPTION

This class implements a generic proxy mechanism for accessing
application objects and their attributes. It defines attributes
of the associated object are accessed. You never instantiate
objects of this class by yourself; they're created internally by
Gtk2::Ex::FormFactory::Context, but you may use the proxy objects
for updates which affect the application object and the GUI as well.

=head1 OBJECT HIERARCHY

  Gtk2::Ex::FormFactory::Proxy

=head1 ATTRIBUTES

Attributes are handled through the common get_ATTR(), set_ATTR()
style accessors.

=over 4

=item B<context> = Gtk2::Ex::FormFactory::Context [mandatory]

The Context this proxy belongs to.

=item B<object> = Object instance | CODEREF

The application object itself or a code reference, which returns
the object instance.

=item B<name> = SCALAR [mandatory]

The Context wide unique name of this Proxy.

=item B<set_prefix> = SCALAR [optional]

This is the method prefix for write accessors. Defaults to B<set_>.

=item B<get_prefix> = SCALAR [optional]

This is the method prefix for read accessors. Defaults to B<get_>.

=item B<attr_accessors_href> = HASHREF [OPTIONAL]

With this hash you can override specific accessors with a code
reference, which is called instead of the object's own accessor.

Refer to Gtk2::Ex::FormFactory::Context->add_object for details.

=item B<attr_activity_href> = HASHREF [OPTIONAL]

This hash defines callbacks for attributes which return the
activity state of the corresonding attribute.

Refer to Gtk2::Ex::FormFactory::Context->add_object for details.

=back

=head1 METHODS

=over 4

=item $app_object = $proxy->B<get_object> ()

This returns the actual application object of this Proxy,
either the statical assigned instance or a dynamicly retrieved
instance.

=item $proxy->B<set_object> ($object)

Changes the application object instance in this Proxy. All dependend
Widgets on the GUI are updated accordingly.

=item $app_object_attr_value = $proxy->B<get_attr> ($attr)

Returns the application object's attribute B<$attr> of this Proxy.

If $attr has the form "object.attr" the attribute of the
correspondent object is retreived, instead of the object associated
with this proxy.

=item $proxy->B<set_attr> ($attr => $value)

Changes the application object's attribute B<$attr> to B<$value> and
updates all dependend Widgets on the GUI accordingly.

If $attr has the form "object.attr" the correspondent object
will be updated, instead of the object associated with this proxy.

=item $proxy->B<set_attrs> ( { $attr => $value, ... } )

Changes a bunch of application object's attributes, which is passed
as a hash reference with B<$attr =&gt; $value> pairs and
updates all dependend Widgets on the GUI accordingly.

=item $activity = $proxy->B<get_attr_activity> ($attr)

Returns the current activity state of B<$attr>.

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