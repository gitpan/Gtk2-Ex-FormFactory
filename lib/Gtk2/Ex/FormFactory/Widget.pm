package Gtk2::Ex::FormFactory::Widget;

use strict;
use Carp;

my $NAME_CNT = 0;
my %WIDGET_NAMES;

#========================================================================
# Accessors for user specified attributes
#========================================================================
sub get_name			{ shift->{name}				}
sub get_object			{ shift->{object}			}
sub get_attr			{ shift->{attr}				}
sub get_properties		{ shift->{properties}			}
sub get_label			{ shift->{label}			}
sub get_label_markup		{ shift->{label_markup}			}
sub get_label_group		{ shift->{label_group}			}
sub get_widget_group		{ shift->{widget_group}			}
sub get_tip			{ shift->{tip}				}
sub get_inactive		{ shift->{inactive}			}
sub get_rules			{ shift->{rules}			}
sub get_expand			{ shift->{expand}			}
sub get_expand_h		{ shift->{expand_h}			}
sub get_expand_v		{ shift->{expand_v}			}
sub get_scrollbars		{ shift->{scrollbars}			}
sub get_signal_connect		{ shift->{signal_connect}		}
sub get_width			{ shift->{width}			}
sub get_height			{ shift->{height}			}
sub get_customize_hook		{ shift->{customize_hook}		}
sub get_changed_hook		{ shift->{changed_hook}			}
#------------------------------------------------------------------------
sub set_name			{ shift->{name}			= $_[1]	}
sub set_object			{ shift->{object}		= $_[1]	}
sub set_attr			{ shift->{attr}			= $_[1]	}
sub set_properties		{ shift->{properties}		= $_[1]	}
sub set_label			{ shift->{label}		= $_[1]	}
sub set_label_markup		{ shift->{label_markup}		= $_[1]	}
sub set_label_group		{ shift->{label_group}		= $_[1]	}
sub set_widget_group		{ shift->{widget_group}		= $_[1]	}
sub set_tip			{ shift->{tip}			= $_[1]	}
sub set_inactive		{ shift->{inactive}		= $_[1]	}
sub set_rules			{ shift->{rules}		= $_[1]	}
sub set_expand			{ shift->{expand}		= $_[1]	}
sub set_expand_h		{ shift->{expand_h}		= $_[1]	}
sub set_expand_v		{ shift->{expand_v}		= $_[1]	}
sub set_scrollbars		{ shift->{scrollbars}		= $_[1]	}
sub set_signal_connect		{ shift->{signal_connect}	= $_[1]	}
sub set_width			{ shift->{width}		= $_[1]	}
sub set_height			{ shift->{height}		= $_[1]	}
sub set_customize_hook		{ shift->{customize_hook}	= $_[1]	}
sub set_changed_hook		{ shift->{changed_hook}		= $_[1]	}
#========================================================================

#========================================================================
# Accessors for internal attributes
#========================================================================
sub get_form_factory		{ shift->{form_factory}			}
sub get_parent			{ shift->{parent}			}
sub get_gtk_widget		{ shift->{gtk_widget}			}
sub get_gtk_parent_widget	{ $_[0]->{gtk_parent_widget} ||
				  $_[0]->{gtk_widget}			}
sub get_gtk_properties_widget	{ $_[0]->{gtk_properties_widget} ||
				  $_[0]->{gtk_widget}			}
sub get_gtk_label_widget	{ shift->{gtk_label_widget}		}
sub get_layout_data		{ shift->{layout_data}			}
sub get_in_update		{ shift->{in_update}			}
sub get_no_widget_update	{ shift->{no_widget_update}		}
sub get_backup_widget_value	{ shift->{backup_widget_value}		}
sub get_widget_activity		{ shift->{widget_activity}		}
#------------------------------------------------------------------------
sub set_form_factory		{ shift->{form_factory}		= $_[1]	}
sub set_parent			{ shift->{parent}		= $_[1]	}
sub set_gtk_widget		{ shift->{gtk_widget}		= $_[1]	}
sub set_gtk_parent_widget	{ shift->{gtk_parent_widget}	= $_[1]	}
sub set_gtk_properties_widget	{ shift->{gtk_properties_widget}= $_[1]	}
sub set_gtk_label_widget	{ shift->{gtk_label_widget}	= $_[1]	}
sub set_layout_data		{ shift->{layout_data}		= $_[1]	}
sub set_in_update		{ shift->{in_update}		= $_[1]	}
sub set_no_widget_update	{ shift->{no_widget_update}	= $_[1]	}
sub set_backup_widget_value	{ shift->{backup_widget_value}	= $_[1]	}
sub set_widget_activity		{ shift->{widget_activity}	= $_[1]	}
#========================================================================

#========================================================================
# Methods, which may be implemented by Widget subclasses
#========================================================================
sub get_type			{ die $_[0]." misses type() method"	}
sub get_gtk_signal_widget	{ $_[0]->get_gtk_widget			}
sub get_gtk_tip_widgets		{ [ $_[0]->get_gtk_widget ] 		}
sub get_widget_check_value 	{ undef	}
sub has_additional_attrs	{ "" 	}
sub has_label			{ 0	}
sub object_to_widget 		{ 1 	}
sub widget_to_object 		{ 1 	}
sub empty_widget		{ 1 	}
sub backup_widget_value 	{ 1 	}
sub restore_widget_value 	{ 1 	}
sub isa_container		{ 0	}
#========================================================================

#========================================================================
# Widget constructor - must be called by subclasses
#========================================================================
sub new {
	my $class = shift;
	my %par = @_;
	my  ($name, $object, $attr, $properties, $label, $label_group) =
	@par{'name','object','attr','properties','label','label_group'};
	my  ($widget_group, $inactive, $rules, $expand, $scrollbars) =
	@par{'widget_group','inactive','rules','expand','scrollbars'};
	my  ($signal_connect, $width, $height, $customize_hook) =
	@par{'signal_connect','width','height','customize_hook'};
	my  ($changed_hook, $tip, $expand_h, $expand_v, $label_markup) =
	@par{'changed_hook','tip','expand_h','expand_v','label_markup'};

	#-- Short notation: 'object.attr', so you may omit 'object'
	if ( $attr =~ /^([^.]+)\.(.*)/ ) {
		$object = $1;
		$attr   = $2;
	}

	#-- Set a default for the Widget's name
	if ( not $name and $object and $attr ) {
		#-- Default name is object.attr, if both
		#-- object and attr are set
		my $cnt = 1;
		my $add = "";
		#-- Add a number, if the name is registered already
		while ( exists $WIDGET_NAMES{"$object.$attr$add"} ) {
			++$cnt;
			$add="_$cnt";
		}
		$name = "$object.$attr$add";

	} elsif ( not $name ) {
		#-- Widgets non associated with an object and
		#-- an attribute get a name derived from the
		#-- Widget's type
		$name ||= $class->get_type."_".$NAME_CNT++;
	}

	#-- Check if widget name is not already registered
	croak "Widget name '$name' is already registered"
		if exists $WIDGET_NAMES{$name};

	#-- Store widget name
	$WIDGET_NAMES{$name} = 1;

	#-- By default make widget insensitive if it's not active	
	$inactive ||= "insensitive";
	
	#-- Expanding defaults
	$expand_h = $expand_v = $expand if defined $expand;
	$expand   = 0 unless defined $expand;
	$expand_h = 1 unless defined $expand_h;
	$expand_v = 0 unless defined $expand_v;
	
	croak "'inactive' must be 'insensitive' or 'invisible'"
		unless  $inactive eq 'insensitive' or
			$inactive eq 'invisible';

	my $self = bless {
		name		=> $name,
		object		=> $object,
		attr		=> $attr,
		properties	=> $properties,
		label		=> $label,
		label_group	=> $label_group,
		label_markup	=> $label_markup,
		widget_group    => $widget_group,
		tip		=> $tip,
		inactive	=> $inactive,
		rules		=> $rules,
		expand		=> $expand,
		expand_h	=> $expand_h,
		expand_v	=> $expand_v,
		scrollbars	=> $scrollbars,
		signal_connect	=> $signal_connect,
		width		=> $width,
		height		=> $height,
		customize_hook	=> $customize_hook,
		changed_hook	=> $changed_hook,
		layout_data	=> {},
	}, $class;
	
	return $self;
}

#========================================================================
# Cleanup of widget data; break circular references
#========================================================================
sub cleanup {
	my $self = shift;
	
	$Gtk2::Ex::FormFactory::DEBUG &&
		print "CLEANUP: ".$self->get_name."(".$self->get_attr.")\n";
	
	#-- Break circular references with the parent object
	$self->set_parent(undef);
	
	#-- Cut references to Gtk widgets - otherwise the Perl
	#-- garbage collector is confused. We have heavy circular
	#-- referencing from FormFactory widgets to Gtk widgets,
	#-- e.g. from callback closures.
	$self->set_gtk_widget(undef);
	$self->set_gtk_parent_widget(undef);
	$self->set_gtk_properties_widget(undef);
	$self->set_gtk_label_widget(undef);

	#-- Deregister the Widget name
	delete $WIDGET_NAMES{$self->get_name};

	#-- Delete all references to this widget from the
	#-- associated Context
	$self->get_form_factory->get_context->deregister_widget ($self);
	
	#-- Destroy reference to the FormFactory
	$self->set_form_factory(undef);

	1;
}

#========================================================================
# Convenience method: get Object Proxy of this Widget
#========================================================================
sub get_proxy {
	$_[0]->get_form_factory
	     ->get_context
	     ->get_proxy($_[0]->get_object);
}

#========================================================================
# Build this Widget, using the FormFactory's Layout instance
#========================================================================
sub build {
	my $self = shift;
	
	$Gtk2::Ex::FormFactory::DEBUG &&
		print "$self->build\n";
	
	#-- The Layout object actually builds all widgets
	$self->get_form_factory
	     ->get_layouter
	     ->build_widget($self);
	
	#-- Register this widget back to its FormFactory
	$self->get_form_factory->register_widget($self);
	
	1;
}

#========================================================================
# Connect all Gtk signals of this widget
#========================================================================
sub connect_signals {
	my $self = shift;

	#-- Some widgets have not Gtk pendant, so there
	#-- may be no signal connecting at all
	my $gtk_widget = $self->get_gtk_widget;
	return unless $gtk_widget;

	#-- Need the context
	my $context = $self->get_form_factory->get_context;

	#-- Register the widget here...
	#-- (deregistering is done in ->cleanup)
	$context->register_widget($self);

	#-- On focus-in we backup the current object value
	#-- (probably we need to restore this if the user
	#--  enters invalid data)
	$gtk_widget->signal_connect ("focus-in-event", sub {
		$self->backup_widget_value;
		0;
	});

	#-- On focus-out we check for valid data
	$gtk_widget->signal_connect ("focus-out-event", sub {
		$self->check_widget_value;
		0;
	});

	#-- Connect the changed signal, if the widgets provides
	#-- a method for this
	$self->connect_changed_signal
		if $self->can("connect_changed_signal");

	#-- Connect additional user specified signals
	my $signal_connect = $self->get_signal_connect;
	if ( $signal_connect ) {
		my $signal_widget = $self->get_gtk_signal_widget;
		while ( my ($signal, $callback) = each %{$signal_connect} ) {
			$signal_widget->signal_connect ( $signal => $callback );
		}
	}

	1;
}

#========================================================================
# Update this widgets resp. transfer the object's value to the Widget
#========================================================================
sub update {
	my $self = shift;
	my ($change_state) = @_;

	#-- Check if widget updating is temoprarily disabled
	#-- (refer to widget_value_changed() for this)
	return if $self->get_no_widget_update;
	return if not $self->get_object;

	#-- We're going to change the widget's state. This will
	#-- trigger the widget's changed signal. To prevent, that
	#-- this triggers an object update again, we set this
	#-- widget into update state (refer to widget_value_changed()
	#-- for details)
	$self->set_in_update(1);

	#-- Transfer object value to widget
	if ( $change_state eq '' ) {
		$self->object_to_widget
			if $self->get_proxy->get_object;
	} elsif ( $change_state =~ /empty/ ) {
		$self->empty_widget;
	}

	#-- Do we have an activity update? (if $change state is given,
	#-- and contains the string 'inactive') - Default is to detect
	#-- activity by the correspondent Proxy method (see below)
	my $active;
	$active = $change_state =~ /inactive/ ? 0 : 1
		if $change_state ne '';

	#-- Now transform the object's activity state into a
	#-- correspondent widget sensivity/visibility.
	if ( $self->get_object and $self->get_gtk_parent_widget ) {
		#-- Get object's activity state
		$active = $self->get_proxy($self->get_object)
			       ->get_attr_activity($self->get_attr)
					if not defined $active;

		#-- And set visibility or sensitivity accordingly,
		#-- dependend on what's defined in the widget
		$self->update_widget_activity ( $active );
	}

	#-- Set widget into normal update state
	$self->set_in_update(0);

	1;
}

#========================================================================
# Update this widget, and it's child; overwritten by Container class
#========================================================================
sub update_all {
	my $self = shift;
	
	#-- For a non Container widget, this is the same as update()
	$self->update(@_);
	
	1;
}

#========================================================================
# Update this widget's activity state: (in)sensitive / (in)visible
#========================================================================
sub update_widget_activity {
	my $self = shift;
	my ($active) = @_;
	
	#-- Use the Widget's activity value over the given $active
	if ( defined $self->get_widget_activity ) {
		$active = $self->get_widget_activity;
	}

	if ( $active ) {
		#-- Make the widget visible resp. sensitive
		if ( $self->get_inactive eq 'invisible' ) {
			$self->get_gtk_parent_widget->show;
			$self->get_gtk_label_widget->show
				if $self->get_gtk_label_widget;
		} else {
			$self->get_gtk_parent_widget->set_sensitive(1);
			$self->get_gtk_label_widget->set_sensitive(1)
				if $self->get_gtk_label_widget;
		}
	} else {
		#-- Make the widget invisible resp. insensitive
		if ( $self->get_inactive eq 'invisible' ) {
			$self->get_gtk_parent_widget->hide;
			$self->get_gtk_label_widget->hide
				if $self->get_gtk_label_widget;
		} else {
			$self->get_gtk_parent_widget->set_sensitive(0);
			$self->get_gtk_label_widget->set_sensitive(0)
				if $self->get_gtk_label_widget;
		}
	}

	1;
}

#========================================================================
# Convenience method: get the Object's value
#========================================================================
sub get_object_value {
	my $self = shift;
	my ($attr) = @_;

	#-- By default get the primary attribute
	$attr ||= $self->get_attr;

	#-- Return nothing if this widget has no associated Object
	return if not $self->get_object;

	#-- Otherweise use the Proxy to return the Object's value
	return $self->get_proxy($self->get_object)
		    ->get_attr ($attr);
}

#========================================================================
# Convenience method: set the Object's value
#========================================================================
sub set_object_value {
	my $self = shift;
	my ($attr, $value) = @_;

	#-- If only one argument is given this is the value of
	#-- the default attribute of this widget
	if ( @_ == 1 ) {
		$value = $attr;
		$attr  = $self->get_attr;
	}

	#-- Do nothing if this widget has no associated Object
	return if not $self->get_object;

	#-- Otherwise use the Proxy to set the Object's value
	return $self->get_proxy($self->get_object)
		    ->set_attr ($attr => $value );
}

#========================================================================
# Check the widget value against the specified rules
#========================================================================
sub check_widget_value {
	my $self = shift;
	
	#-- Return true, if this Widget has no associated rules
	my $rules = $self->get_rules;
	return 1 if not defined $rules;

	#-- Rule checking is done by a Rules Object associated
	#-- with the FormFactory of this Widget
	my $rule_checker = $self->get_form_factory->get_rule_checker;

	my $message;
	if ( $self->get_form_factory->get_sync ) {
		#-- If the FormFactory is in Sync mode, check
		#-- the Object's value (access is faster than getting
		#-- the Widget value)
		$message = $rule_checker->check (
			$rules,
			$self->get_label,
			$self->get_object_value
		);
	} else {
		#-- If the FormFactory is not in Sync mode, the
		#-- Widget value is checked
		$message = $rule_checker->check (
			$rules,
			$self->get_label,
			$self->get_widget_check_value
		);
	}

	#-- Restore the Widget value and print an error dialog,
	#-- if the Rule check failed.
	if ( $message ) {
		$self->restore_widget_value;
		$self->show_error_message (
			message => $message,
		);
	}
	
	return 0;
}

#========================================================================
# Callback method, called if the user changed the Widget
#========================================================================
sub widget_value_changed {
	my $self = shift;

	#-- Do nothing if this Widget is already in update state
	#-- (otherwise recursive updates may be triggered)
	return if $self->get_in_update;
	
	$Gtk2::Ex::FormFactory::DEBUG &&
	    print $self->get_type."(".$self->get_name.") value changed\n";

	if ( $self->get_form_factory->get_sync ) {
		#-- Apply all changes and update dependent
		#-- widgets accordingly
		$self->apply_changes;

		#-- Call the Widget's change hook, if one was set
		my $changed_hook = $self->get_changed_hook;
		&$changed_hook($self->get_proxy->get_object, $self)
			if $changed_hook;

	} else {
		#-- Changing the object normally triggers this
		#-- change also in the widget (refer to
		#-- Context->update_object_attr_widgets). We need 
		#-- to prevent this.
		$self->set_no_widget_update(1);

		#-- Call the Widget's change hook, if one was set,
		#-- BEFORE dependet widgets are updated. Probably
		#-- the widget update depends on stuff in the
		#-- changed_hook.
		my $changed_hook = $self->get_changed_hook;
		&$changed_hook($self->get_proxy->get_object, $self)
			if $changed_hook;

		#-- Now update all dependent widgets
		$self->get_form_factory
		     ->get_context
		     ->update_object_attr_widgets(
		     	$self->get_object, $self->get_attr
		     );

		#-- Set widget into normal update state again
		$self->set_no_widget_update(0);
	}

	1;
}

#========================================================================
# Transfer the Widget value to the Object; no activity update
#========================================================================
sub apply_changes {
	my $self = shift;

	$Gtk2::Ex::FormFactory::DEBUG &&
	    print "apply_changes ".$self->get_type."(".$self->get_name.")\n";
	
	#-- No widget update when setting the object value
	$self->set_no_widget_update(1);

	#-- Set object value from current widget value
	$self->widget_to_object;

	#-- Widget updates allowed again
	$self->set_no_widget_update(0);
	
	1;
}

#========================================================================
# Apply all changes incl. children
# (here the samy as apply, overriden by Container)
#========================================================================
sub apply_changes_all { shift->apply_changes }

#========================================================================
# Show an error dialog
#========================================================================
sub show_error_message {
	my $self = shift;
	my %par = @_;
	my ($message, $type) = @par{'message','type'};

	$type ||= "error";

	$type = "GTK_MESSAGE_".uc($type);

	my $dialog = Gtk2::MessageDialog->new (
		$self->get_form_factory->get_form_factory_gtk_window,
		'GTK_DIALOG_DESTROY_WITH_PARENT',
		$type,
		'GTK_BUTTONS_CLOSE',
		$message,
	);

	$dialog->signal_connect( "response", sub { $dialog->destroy } );
	$dialog->set_position ('center');
	$dialog->set ( modal => 1 );
	$dialog->show;

	1;	
}

1;

__END__

=head1 NAME

Gtk2::Ex::FormFactory::Widget - Base class for all FormFactory
Widgets

=head1 SYNOPSIS

  Gtk2::Ex::FormFactory::Widget->new (
    name	   => Name of this Widget,
    object	   => Name of the associated application object,
    attr	   => Attribute represented by the Widget,
    label	   => Label text,
    label_markup   => Boolean, indicating whether the label has markup,
    label_group    => Name of a Gtk2::SizeGroup for the label,
    widget_group   => Name of a Gtk2::SizeGroup for the widget,
    tip 	   => Tooltip text,
    properties	   => { Gtk2 Properties ... }
    inactive	   => 'insensitive' | 'invisible',
    rules	   => [ Rules for this Widget ],
    expand	   => Boolean: should the Widget expand?,
    expand_h	   => Boolean: should the Widget expand horizontally?,
    expand_v	   => Boolean: should the Widget expand vertically?,
    scrollbars	   => [ hscrollbar_policy, vscrollbar_policy ],
    signal_connect => { signal => CODREF, ... },
    width	   => Desired width,
    height	   => Desired height,
    customize_hook => CODEREF: Customize the underlying Gtk2 Widget,
    changed_hook   => CODEREF: Track changes made to the Widget,
  );

=head1 DESCRIPTION

This is an abstract base class and usually not used directly from the
application. For daily programming the attributes defined in this
class are most important, since they are common to all Widgets of the
Gtk2::Ex::FormFactory framework.

=head1 OBJECT HIERARCHY

  Gtk2::Ex::FormFactory::Intro

  Gtk2::Ex::FormFactory::Widget
  +--- Gtk2::Ex::FormFactory::Container
  |    +--- Gtk2::Ex::FormFactory
  |    +--- Gtk2::Ex::FormFactory::Expander
  |    +--- Gtk2::Ex::FormFactory::Form
  |    +--- Gtk2::Ex::FormFactory::HBox
  |    +--- Gtk2::Ex::FormFactory::Notebook
  |    +--- Gtk2::Ex::FormFactory::Table
  |    +--- Gtk2::Ex::FormFactory::VBox
  |    +--- Gtk2::Ex::FormFactory::Window
  +--- Gtk2::Ex::FormFactory::Button
  +--- Gtk2::Ex::FormFactory::CheckButton
  +--- Gtk2::Ex::FormFactory::CheckButtonGroup
  +--- Gtk2::Ex::FormFactory::Combo
  +--- Gtk2::Ex::FormFactory::DialogButtons
  +--- Gtk2::Ex::FormFactory::Entry
  +--- Gtk2::Ex::FormFactory::GtkWidget
  +--- Gtk2::Ex::FormFactory::HSeparator
  +--- Gtk2::Ex::FormFactory::Image
  +--- Gtk2::Ex::FormFactory::Label
  +--- Gtk2::Ex::FormFactory::List
  +--- Gtk2::Ex::FormFactory::Menu
  +--- Gtk2::Ex::FormFactory::Popup
  +--- Gtk2::Ex::FormFactory::ProgressBar
  +--- Gtk2::Ex::FormFactory::RadioButton
  +--- Gtk2::Ex::FormFactory::TextView
  +--- Gtk2::Ex::FormFactory::Timestamp
  +--- Gtk2::Ex::FormFactory::ToggleButton
  +--- Gtk2::Ex::FormFactory::VSeparator
  +--- Gtk2::Ex::FormFactory::YesNo

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

=item B<name> = SCALAR [optional]

Each widget has a unique name. If you don't specify it explicitly a
name is generated automatically.

=item B<object> = SCALAR [optional]

The name of the object, which controls this widget. This object name
must be registered at the L<Gtk2::Ex::FormFactory::Context> of the
L<Gtk2::Ex::FormFactory> associated with this Widget.

=item B<attr> = SCALAR [optional]

Usually a Widget represents a specific object attribute, e.g. a text
entry shows the current value of the attribute you specify here. How
this attribute is accessed is defined in the
L<Gtk2::Ex::FormFactory::Context> instance.

=item B<label> = SCALAR [optional]

Each Widget may have an associated label. How this label is actually
rendered depends on the L<Gtk2::Ex::FormFactory::Container> to which
this Widget was added. E.g. L<Gtk2::Ex::FormFactory::Form> implements
a simple two column table with the labels in the left and the widgets
in the right column.

=item B<label_markup> = BOOLEAN [optional]

If this is set to a true value, the label will be rendered with
a HTML like markup. Refer to the chapter "Pango Text Attribute Markup"
of the official Gtk documentation for details about the known markup tags.

=item B<label_group> = SCALAR [optional]

If you have a complex layout and you want to align your labels
although they are not part of the same container you can specify an
arbitrary name of a label group here. A correspondent Gtk2::SizeGroup
is managed automatically for you. Simply specify the same name for
all Widgets for which you want to have the same label size.

=item B<widget_group> = SCALAR [optional]

This is very similar to the B<label_group> attribute. The difference
is that the size allocated by the Widget is under control of a
Gtk2::SizeGroup.

=item B<tip> = SCALAR [optional]

Optional text of the tooltip of this Widget.

=item B<properties> = HASHREF [optional]

This is a hash of Gtk+ properties for this Widget, e.g. you can
specify { border_width => 5 } here to manipulate the border-width of
this specific Widget. You should use this with care, because this
breaks the strict isolation of GUI structure and appearance. Probably
it's better to implement an own L<Gtk2::Ex::FormFactory::Layout>
class, where you can control appearance of your widgets in a much
more generic way.

=item B<inactive> = 'insensitive' | 'invisible' [optional]

Gtk2::Ex::FormFactory automatically manages the activity state of
your Widgets. Specify if you want the Widget getting insensitive or
invisible when the Widget is deactivated. This defaults to
B<'insensitive'>.

=item B<rules> = rule | [ rule, ... ] [optional]

Data entered by the user must apply the rules specified here. Refer
to L<Gtk2::Ex::FormFactory::Rules> for details about rules.

=item B<expand> = BOOL [optional]

By default a Widget doesn't expand into the space which is avaiable
from its container. Specify a TRUE value to activate Widget
expansion. Whether the Widget expands vertically or horizontally
depends on its Container. E.g. in a VBox it will expand vertically,
in a HBox horizontally.

=item B<expand_h> = BOOL [optional]

=item B<expand_v> = BOOL [optional]

Some containers can expand the Widget in both directions, e.g. a
Gtk2::Table. If your widget is added to such a container (e.g. to a
L<Gtk2::Ex::FormFactory::Form>, which is implemented with a
Gtk2::Table) you can specify both directions of expansion here.

B<expand_h> defaults to TRUE and B<expand_v> to FALSE, or to
B<expand> if specified.

=item B<scrollbars> = [ h_policy, v_policy ] [optional]

If you want your Widget inside a Gtk2::ScrolledWindow, simply specify
the policy for horizontal and vertical scrollbars here. Possible
values are: B<"always">, B<"automatic"> or B<"never">.

=item B<changed_hook> = CODEREF(ApplicationObject) [optional]

This code reference is called after the user changed a value of the
Widget and these changes were applied to the underlying application
object. The application object is the first argument of the call.

=item B<signal_connect> = HASHREF [optional]

Specify all your signal connections in a single hash reference. Key
is the name of the signal, and value the callback (a static
subroutine reference or a closure).

B<Note>: don't use this to track changes made on the GUI!
Gtk2::Ex::FormFactory manages this for you. If you want to be
notified about changes, use the Widget transparent B<changed_hook>
described above.

=item B<width> = INTEGER [optional]

=item B<height> = INTEGER [optional]

You can specify a desired width and/or height. Use this with care,
because this destroys many of Gtk's dynamic layout capablities.
Internally B<Gtk2::Widget-&gt;size_request> is used for this feature.

=item B<customize_hook> = CODEREF(Gtk2::Widget) [optional]

This code reference is called after the Gtk2::Widget's are built. The
Gtk2::Widget object of this Gtk2::Ex::FormFactory::Widget is the
first argument of this call.

You can use this hook to do very specific customization with this
Widget. Again: use this with care, probably implement your own
L<Gtk2::Ex::FormFactory::Layout> class to control the layout.

=back

=head1 METHODS

=over 4

=item $widget->B<update> ()

Updates this specific Widget resp. sets it's state to the value
from the associated application object attribute. In case of a
Container the child widgets are B<not> updated.

=item $widget->B<update_all> ()

Same as B<update>, but containers will update their children as well.

=item $widget->B<update_widget_activity> ()

Only update the Widget's activity state.

=item $app_object_attr_value = $widget->B<get_object_value> ([$attr])

A convenience method to get the actual value of an associated
application object attribute. If B<$attr> is omitted, the default
attribute is used.

=item $widget->B<set_object_value> ( [$attr, ] $value )

A convenience method to set the actual value of an associated
application object attribute to B<$value>. If B<$attr> is omitted,
the default attribute is used.

=item $widget->B<check_widget_value> ()

Checks the current Widget value against the rules provided for
this Widget. An error dialog is opened if the rule check failed
and the previous value is restored automatically. Nothing happens
if all rules apply.

=item $widget->B<widget_value_changed> ()

This method is called if the Widget value was changed. All Widget
implementations of Gtk2::Ex::FormFactory must connect their specific
"changed" signal to this method call.

=item $widget->B<apply_changes> ()

Copy the Widget value to the associated application object attribute.
In a FormFactory with the B<sync> flag set to TRUE this happens
on each change. If the FormFactory is asynchronous it's called only
when the user hit the Ok button.

=item $widget->B<show_error_message> ( message => $message, type => $type )

Small convenience method which opens a Gtk+ error dialog with
B<$message>. B<$type> defaults to 'error', but you can specify
'info', 'warning' and 'question' as well to get corresponding
dialogs.

=item $proxy = $widget->B<get_proxy> ()

Convenience method which returns the Gtk2::Ex::FormFactory::Proxy
instance for the object associated with this Widget.

=back

The following methods are used by the Gtk2::Ex::FormFactory::Layout
module, so you need them only if you implement your own layout.

=over 4

=item $widget->B<set_gtk_widget> (Gtk2::Widget)

The Gtk2::Widget which represents the associated application
object attribute, e.g. this is a Gtk2::Entry for a
Gtk2::Ex::FormFactory::Entry widget.

=item $widget->B<set_gtk_parent_widget> (Gtk2::Widget)

Often the real Gtk2 widget is inside a container, e.g. a
Gtk2::Frame. The Gtk2 widget of the container needs to be set
explicetly using this method.

=back

=head1 IMPLEMENT NEW WIDGETS

You can implement new widgets by subclassing Gtk2::Ex::FormFactory::Widget
or Gtk2::Ex::FormFactory::Container.

You need to implement the following methods (not all are mandatory, e.g.
if your Widget is a container actually doesn't representing
any application object value, you can omit most of them):

=over 4

=item $self->B<get_type>() [mandatory]

This returns the short name of your Widget. It should be lower case
and may contain underscores. If you wrap an existent Gtk2 widget
try to derive the type name from the widget's name.

=item $self->B<object_to_widget> [optional]

This method transfers the value of the associated application
object attribute to your widget. You may use the convenience method
$self->B<get_object_value>() to get the value of the default
attribute of this widget.

=item $self->B<widget_to_object> [optional]

This method transfers the value of your widget to the associated
application object attribute. You may use the convenience method
$self->B<set_object_value>($value) to set the value of the default
attribute of this widget.

=item $self->B<empty_widget> [optional]

This method sets your widget to an empty value, e.g. an Image widget
should display nothing, or the text of some sort of text entry should
be deleted.

=item $self->B<backup_widget_value> [optional]

This method makes a backup of the current widget value.
Gtk2::Ex::FormFactory::Widget has a convenience method for setting
the backup value you may use: $self->B<set_backup_widget_value>($value).
If your widget has a more complex value, which can't be covered by
a single scalar, the implementation must care about this.

=item $self->B<restore_widget_value> [optional]

This restores a value from the backup created with
$self->B<backup_widget_value>().

=item $self->B<get_widget_check_value> [optional]

Currently Gtk2::Ex::FormFactory::Rules can only check a single
scalar value. Your widget must implement this method to return
the correspondent value.

=item $self->B<connect_changed_signal> [optional]

This method must connect the "changed" signal of the specific
Gtk2 widget your implementation uses. The connected callback
must call the $self->B<widget_value_changed>() method, so
Gtk2::Ex::FormFactory can track all changes on the GUI.

=item $gtk_widget = $self->B<get_gtk_signal_widget>() [optional]

This defaults to $self->B<get_gtk_widget>() and returns the
Gtk2 widget to which additional user specified signals
should be connected.

=item $gtk_widget = $self->B<get_gtk_properties_widget>() [optional]

This defaults to $self->B<get_gtk_widget>() and returns the
Gtk2 widget which should get the B<properties> defined for this
Gtk2::Ex::FormFactory widget. This is useful if the actual GtkWidget
is not the B<gtk_widget> (e.g. Gtk2::Ex::FormFactory::Window needs
this, since it's finally a VBox, but you want to apply properties
like default_width to the GtkWindow and not to the VBox).

=item $widgets_lref = $self->B<get_gtk_tip_widgets>() [optional]

This defaults to [ $self->B<get_gtk_widget>() ] and returns
a list reference of Gtk2 widgets which should
get a tooltip, if the user specified one. 

=item $self->B<has_additional_attrs>() [optional]

If your widget supports additional application object attributes
which should be managed automatically, this method returns
a list reference of symbolic names for these attributes. Please
refer to the implementation of Gtk2::Ex::FormFactory::List,
which uses this feature to store the actually selected item(s)
in the application object.

=item BOOL = $self->B<has_label>() [optional]

This defaults to 0. Set this to 1 if your widget manage it's
label by itself (like a Gtk2::CheckBox does).

=back

=head2 Creating the Gtk2 widget(s)

You probably recognized that a method which actually builds the
Gtk2 widgets of your widget is missing here. This is covered
by the Gtk2::Ex::FormFactory::Layout module. So create your
own layouter and add the $layouter->B<build_TYPE>($widget)
method for your widget to it. If your widget is a container you also
need to implement at least the generic $layouter->B<add_widget_to_TYPE>
method. For details about this please refer to the documentation
of Gtk2::Ex::FormFactory::Layout.

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
