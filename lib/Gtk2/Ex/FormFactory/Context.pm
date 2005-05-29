package Gtk2::Ex::FormFactory::Context;

use strict;
use Carp;

use Gtk2::Ex::FormFactory::Proxy;

sub get_proxies_by_name		{ shift->{proxies_by_name}		}
sub get_widgets_by_attr		{ shift->{widgets_by_attr}		}
sub get_widgets_by_object	{ shift->{widgets_by_object}		}
sub get_depend_trigger_href	{ shift->{depend_trigger_href}		}
sub get_update_hooks_by_object	{ shift->{update_hooks_by_object}	}

sub get_default_set_prefix	{ shift->{default_set_prefix}		}
sub get_default_get_prefix	{ shift->{default_get_prefix}		}

sub set_default_set_prefix	{ shift->{default_set_prefix}	= $_[1]	}
sub set_default_get_prefix	{ shift->{default_get_prefix}	= $_[1]	}

sub new {
	my $class = shift;
	my %par = @_;
	my  ($default_set_prefix, $default_get_prefix) =
	@par{'default_set_prefix','default_get_prefix'};

	$default_set_prefix = "set_" if not defined $default_set_prefix;
	$default_get_prefix = "get_" if not defined $default_get_prefix;

	my $self = bless {
		default_set_prefix	=> $default_set_prefix,
		default_get_prefix	=> $default_get_prefix,
		proxies_by_name		=> {},
		widgets_by_attr		=> {},
		widgets_by_object	=> {},
		update_hooks_by_object  => {},
		depend_trigger_href	=> {},
	}, $class;
	
	$self->add_object(
		name   => "__dummy",
		object => bless {}, "Gtk2::Ex::FormFactory::Dummy",
	);
	
	return $self;
}

sub add_object {
	my $self = shift;
	my %par = @_;
	my  ($name, $object, $set_prefix, $get_prefix, $attr_activity_href) =
	@par{'name','object','set_prefix','get_prefix','attr_activity_href'};
	my  ($attr_depends_href, $attr_accessors_href, $update_hook) =
	@par{'attr_depends_href','attr_accessors_href','update_hook'};

	$set_prefix ||= $self->get_default_set_prefix;
	$get_prefix ||= $self->get_default_get_prefix;

	if ( $attr_depends_href ) {
		my $depend_trigger_href = $self->get_depend_trigger_href;
		foreach my $attr ( keys %{$attr_depends_href} ) {
			if ( not ref $attr_depends_href->{$attr} ) {
				$depend_trigger_href->{$attr_depends_href->{$attr}}->{"$name.$attr"} = 1;
			} elsif ( ref $attr_depends_href->{$attr} eq 'ARRAY' ) {
				$depend_trigger_href->{$_}->{"$name.$attr"} = 1
					for @{$attr_depends_href->{$attr}};
			} else {
				croak "Illegal attr_depends_href value for attribute '$attr'";
			}
		}
	}

	my $proxies_by_name = $self->get_proxies_by_name;

	die "Object with name '$name' already registered to this context"
		if $proxies_by_name->{$name};

	$self->get_update_hooks_by_object->{$name} = $update_hook
		if $update_hook;

	return $proxies_by_name->{$name} = Gtk2::Ex::FormFactory::Proxy->new (
		    context       	=> $self,
		    name          	=> $name,
		    object        	=> $object,
		    set_prefix    	=> $set_prefix,
		    get_prefix    	=> $get_prefix,
		    attr_activity_href	=> $attr_activity_href,
		    attr_accessors_href	=> $attr_accessors_href,
	);
}

sub remove_object {
	my $self = shift;
	my ($name) = @_;

	my $proxies_by_name = $self->get_proxies_by_name;
	
	die "Object with name '$name' not registered to this context"
		unless $proxies_by_name->{$name};

	delete $proxies_by_name->{$name};

	1;
}

sub register_widget {
	my $self = shift;
	my ($widget) = @_;
	
	my $object_attr =
		$widget->get_object.".".
		$widget->get_attr;

	return if $object_attr eq '.';

	my $widget_full_name =
		$widget->get_form_factory->get_name.".".
		$widget->get_name;

	$Gtk2::Ex::FormFactory::DEBUG &&
	    print "REGISTER: $object_attr => $widget_full_name\n";

	$self->get_widgets_by_attr
	     ->{$object_attr}
	     ->{$widget_full_name} = $widget;
	
	if ( $widget->has_additional_attrs ) {
		my $add_attrs = $widget->has_additional_attrs;
		my $object = $widget->get_object;
		foreach my $add_attr ( @{$add_attrs} ) {
			my $get_attr_name_method = "get_attr_$add_attr";
			my $attr = $widget->$get_attr_name_method();
			$self->get_widgets_by_attr
			     ->{"$object.$attr"}
			     ->{$widget_full_name} = $widget;
		}
	}	
	
	$self->get_widgets_by_object
	     ->{$widget->get_object}
	     ->{$widget_full_name} = $widget;

	1;
}

sub deregister_widget {
	my $self = shift;
	my ($widget) = @_;

	$Gtk2::Ex::FormFactory::DEBUG &&
	    print "DEREGISTER ".$widget->get_name."\n";
	
	return if not $widget->get_object or
		      $widget->get_object eq '__dummy';

	my $widget_full_name =
		$widget->get_form_factory->get_name.".".
		$widget->get_name;

	my $object_attr =
		$widget->get_object.".".
		$widget->get_attr;

	$Gtk2::Ex::FormFactory::DEBUG &&
	    print "DEREGISTER: $object_attr => $widget_full_name\n";

	warn "Widget not registered ($object_attr => $widget_full_name)"
		unless $self->get_widgets_by_attr
			    ->{$object_attr}
			    ->{$widget_full_name};

	delete $self->get_widgets_by_attr
		    ->{$object_attr}
		    ->{$widget_full_name};
	
	if ( $widget->has_additional_attrs ) {
		my $add_attrs = $widget->has_additional_attrs;
		my $object = $widget->get_object;
		foreach my $add_attr ( @{$add_attrs} ) {
			my $get_attr_name_method = "get_attr_$add_attr";
			my $attr = $widget->$get_attr_name_method();
			delete $self->get_widgets_by_attr
				    ->{"$object.$attr"}
				    ->{$widget_full_name};
		}
	}	

	delete $self->get_widgets_by_object
		    ->{$widget->get_object}
		    ->{$widget_full_name};

	1;
}

sub get_proxy {
	my $self = shift;
	my ($name) = @_;

	my $proxy = $self->get_proxies_by_name->{$name};

	croak "Object '$name' not added to this context"
		unless $proxy;
		
	return $proxy;
}

sub get_object {
	my $self = shift;
	my ($name) = @_;

	my $proxy = $self->get_proxies_by_name->{$name};

	croak "Object '$name' not added to this context"
		unless $proxy;
	
	return $proxy->get_object;
}

sub set_object {
	my $self = shift;
	my ($name, $object) = @_;

	my $proxy = $self->get_proxies_by_name->{$name};

	croak "Object $name not added to this context"
		unless $proxy;

	$proxy->set_object($object);
	
	return $object;
}

sub update_object_attr_widgets {
	my $self = shift;
	my ($object, $attr) = @_;

	$Gtk2::Ex::FormFactory::DEBUG &&
	    print "update_object_attr_widgets($object, $attr)\n";

	my $widgets_by_attr      = $self->get_widgets_by_attr;
	my $depend_trigger_href  = $self->get_depend_trigger_href;

	$_->update for values %{$widgets_by_attr->{"$object.$attr"}};

	foreach my $update_object_attr ( keys %{$depend_trigger_href->{"$object.$attr"}} ) {
		$_->update for values %{$widgets_by_attr->{$update_object_attr}};
	}

	1;
}

sub update_object_widgets {
	my $self = shift;
	my ($name) = @_;

	$Gtk2::Ex::FormFactory::DEBUG &&
	    print "update_object_widgets($name)\n";

	my $object       = $self->get_object($name);
	my $change_state = defined $object ? '' : 'empty,inactive';

	my $widgets_by_object = $self->get_widgets_by_object;
	$_->update($change_state)
		for values %{$widgets_by_object->{$name}};

	my $update_hook = $self->get_update_hooks_by_object->{$name};
	&$update_hook($object) if $update_hook;

	1;
}

sub update_object_widgets_activity {
	my $self = shift;
	my ($name, $activity) = @_;

	warn "activity !(empty|inactive|active)"
		unless $activity =~ /^empty|inactive|active$/;

	$Gtk2::Ex::FormFactory::DEBUG &&
	    print "update_object_activity($name)\n";

	my $widgets_by_object = $self->get_widgets_by_object;

	$_->update($activity)
		for values %{$widgets_by_object->{$name}};

	1;
}

1;

__END__

=head1 NAME

Gtk2::Ex::FormFactory::Context - Context in a FormFactory framework

=head1 SYNOPSIS

  my $context = Gtk2::Ex::FormFactory::Context->new (
    default_get_prefix => Default prefix for read accessors,
    default_set_prefix => Default prefix for write accessors,
  );
  
  $context->add_object (
    name                => Name of the application object in
    			   this Context,
    object              => The application object itself or a
    			   callback which returns the object,
    get_prefix          => Prefix for read accessors,
    set_prefix          => Prefix for write accessors,
    attr_activity_href  => Hash of CODEREFS for attributes which return
			   activity of the corresponding attributes,
    attr_depends_href   => Hash defining attribute dependencies,
    attr_accessors_href => Hash of CODEREFS which override correspondent
    			   accessors in this Context,
  );

=head1 DESCRIPTION

This module implements a very importent concept of the
Gtk2::Ex::FormFactory framework.

The Context knows of all
your application objects, how attributes of the objects
can be accessed (for reading and writing), which attributes
probably depend on other attributes and knows of how to control
the activity state of attributes resp. of the Widgets which
represent these attributes.

So the Context is a layer between your application objects and
the GUI which represents particular attributes of your objects.

=head1 OBJECT HIERARCHY

  Gtk2::Ex::FormFactory::Context

=head1 ATTRIBUTES

Attributes are handled through the common get_ATTR(), set_ATTR()
style accessors, but they are mostly passed once to the object
constructor and must not be altered after associated FormFactory's
were built.

=over 4

=item B<default_get_prefix> = SCALAR [optional]

Usually your application's objects use a common prefix for all
attribute accessors. This defines the default prefix for read
accessors and defaults to "B<get_>".

=item B<default_set_prefix> = SCALAR [optional]

Usually your application's objects use a common prefix for all
attribute accessors. This defines the default prefix for write
accessors and defaults to "B<set_>".

=back

=head1 METHODS

=over 4

=item $context->B<add_object> (...)

All your application objects must be added to the Context using
this method. Parameters are passed to the method as a hash:

=over 4

=item B<name> = SCALAR [mandatory]

Each object in a Context need a unique name, so this parameter
is mandatory. You refer to this name when you create Widgets and
want to associate these with your application object's attributes.

=item B<object> = BLESSED REF|CODEREF [optional]

This is the application object itself, or a code reference which
returns the object. Using the code reference option gives you
very flexible control. E.g. this way you can dynamically define the
"actually selected track of a disc" in an imaginary Audio CD
library program. But also note that this may have some impact on
performance, because this code reference will be called quite often.

An application object in terms of the Context may become undef,
that's why the B<object> parameter is optional here. Also the
code reference may return undef.

Once an object gets undef, all
associated widgets will be set inactive automatically. You can
control per widget if it should render invisible or insensitive
in that case. Refer to L<Gtk2::Ex::FormFactory::Widget> for
details.

=item B<get_prefix> = SCALAR [optional]

With this parameter you can override the B<default_get_prefix>
setting of this Context for this object.

=item B<set_prefix> = SCALAR [optional]

With this parameter you can override the B<default_set_prefix>
setting of this Context for this object.

=item B<attr_accessors_href> = HASHREF [OPTIONAL]

Often your application object attribute values doesn't fit the
data type a particular Widget expects, e.g. in case of the
Gtk2::Ex::FormFactory::List widget, which expects a two dimensional
array for its content.

Since you need this conversion only for a particular GUI task it
makes sense to implement the conversion routine in the Context
instead of adding such GUI specific methods to your underlying
classes, which should be as much GUI independent as possible.

That's why you can override arbitrary accessors (read and write) using the
B<attr_accessors_href> parameter. Key is the name of method to
be overriden and value a code reference, which is called instead
of the real method.

The code reference gets your application object as the first parameter,
as usual for object methods, and additionally the new value in case of
write access.

A short example. Here we override the accessors B<get_tracks> and
B<set_tracks> of an imagnary B<disc> object, which represents an
audio CD. The track title is stored as a simple array and needs
to be converted to a two dimensional array as expected by
Gtk2::Ex::FormFactory::List:

  $context->add_object (
    name => "disc",
    attr_accessors_href => {
      get_tracks => sub {
        my $disc = shift;
	#-- Convert the one dimensional array of disc
	#-- tracks to the two dimensional array expected
	#-- by Gtk2::Ex::FormFactory::List. Also the number
	#-- of the track is added to the first column here
	my @list;
	my $nr = 1;
	foreach my $track ( @{$disc->get_tracks} ) {
	  push @list, [ $nr++, $track ];
	}
	return\@list;
      },
      set_tracks => sub {
        my $disc = shift;
	my ($list_ref) = @_;
	#-- Convert the array back (the List is editable in
	#-- our example, so values can be changed).
	my @list;
	foreach my $row ( @{$list_ref} ) {
		push @list, $row->[1];
	}
	$disc->set_tracks(\@list);
	return \@list;
      },
    },
  );
    

=item B<attr_activity_href> = HASHREF [OPTIONAL]

As mentioned earlier activity of Widgets is controlled by
the Gtk2::Ex::FormFactory framework. E.g. if the an object
becomes undef, all associated widgets render inactive.

With the B<attr_activity_href> setting you can handle
activity on attribute level, not only on object level.

The key of the hash is the attribute name and value is
a code reference, which returns TRUE or FALSE and control
the activity this way.

Again an example: imagine a text entry which usually is
set with a default value controlled by your application.
But if the user wants to override the entry he first has
to press a correpondent checkbox to activate this.

  $context->add_object (
    name => "person",
    attr_activity_href => sub {
      ident_number => sub {
        my $person = shift;
	return $person->get_may_override_ident_number;
      },
    },
    attr_depends_href => sub {
      ident_number => "person.may_override_ident_number",
    },
  );

For details about the B<attr_depends_href> option read on.

=item B<attr_depends_href> = HASHREF [OPTIONAL]

This hash defines dependencies between attributes. If you
look at the example above you see why this is necessary.
The B<ident_number> of a person may be overriden only if
the B<may_override_ident_number> attribute of this person
is set. Since this dependency is coded inside the code
reference, Gtk2::Ex::FormFactory isn't aware of it until
you add a corresponding B<attr_depends_href> entry.

Now the GUI will automatically activate the Widget for
the B<ident_number> attribute once B<may_override_ident_number>
is set, e.g. by a CheckBox the user clicked.

If an attribute depends on more than one other attributes
you can use a list reference:

  attr_depends_href => sub {
      ident_number => [
        "person.may_override_ident_number",
	"foo.bar",
      ],
  },

=back

=item $context->B<remove_object> ( $name )

Remove the object $name from this context.

=item $app_object = $context->B<get_object> ( $name )

This returns the application object registered as B<$name>
to this context.

=item $context->B<set_object> ( $name => $object )

This sets a new object, which was registered as B<$name>
to this context.

=item $context->B<update_object_attr_widgets> ( $object_name, $attr_name )

Triggers updates on all GUI widgets which are associated with
the attribute B<$attr_name> of the object registered as B<$object_name>
to this context.

=item $context->B<update_object_widgets> ( $object_name )

Triggers updates on all GUI widgets which are associated with
the object registered as B<$object_name> to this context.

=item $context->B<update_object_widgets_activity> ( $object_name, $activity )

This updates the activity state of all GUI widgets which are
associated with the object registered as B<$object_name> to
this context.

B<$activity> is 'inactive' or 'active'.

=item $proxy = $context->B<get_proxy> ( $object_name )

This returns the Gtk2::Ex::FormFactory::Proxy instance which was
created for the object registered as B<$name> to this context.
With the proxy you can do updates on object attributes which
trigger the correspondent GUI updates as well.

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
