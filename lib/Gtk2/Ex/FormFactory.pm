package Gtk2::Ex::FormFactory;

$VERSION = "0.51";

use strict;

use base qw( Gtk2::Ex::FormFactory::Container );

use Gtk2;

sub get_type { "form_factory" }

use Gtk2::Ex::FormFactory::Context;
use Gtk2::Ex::FormFactory::Layout;
use Gtk2::Ex::FormFactory::Rules;

use Gtk2::Ex::FormFactory::Button;
use Gtk2::Ex::FormFactory::CheckButton;
use Gtk2::Ex::FormFactory::Combo;
use Gtk2::Ex::FormFactory::DialogButtons;
use Gtk2::Ex::FormFactory::Entry;
use Gtk2::Ex::FormFactory::Expander;
use Gtk2::Ex::FormFactory::Form;
use Gtk2::Ex::FormFactory::HBox;
use Gtk2::Ex::FormFactory::HSeparator;
use Gtk2::Ex::FormFactory::Image;
use Gtk2::Ex::FormFactory::Label;
use Gtk2::Ex::FormFactory::List;
use Gtk2::Ex::FormFactory::Menu;
use Gtk2::Ex::FormFactory::Notebook;
use Gtk2::Ex::FormFactory::Popup;
use Gtk2::Ex::FormFactory::ProgressBar;
use Gtk2::Ex::FormFactory::RadioButton;
use Gtk2::Ex::FormFactory::Table;
use Gtk2::Ex::FormFactory::ToggleButton;
use Gtk2::Ex::FormFactory::VBox;
use Gtk2::Ex::FormFactory::Window;
use Gtk2::Ex::FormFactory::YesNo;

sub get_context			{ shift->{context}			}
sub get_sync			{ shift->{sync}				}
sub get_layouter		{ shift->{layouter}			}
sub get_rule_checker		{ shift->{rule_checker}			}
sub get_ok_hook			{ shift->{ok_hook}			}
sub get_no_widget_updates	{ shift->{no_widget_updates}		}
sub get_gtk_size_groups		{ shift->{gtk_size_groups}		}

sub set_context			{ shift->{context}		= $_[1]	}
sub set_sync			{ shift->{sync}			= $_[1]	}
sub set_layouter		{ shift->{layouter}		= $_[1]	}
sub set_rule_checker		{ shift->{rule_checker}		= $_[1]	}
sub set_ok_hook			{ shift->{ok_hook}		= $_[1]	}
sub set_no_widget_updates	{ shift->{no_widget_updates}	= $_[1]	}
sub set_gtk_size_groups		{ shift->{gtk_size_groups}	= $_[1]	}

sub get_form_factory		{ shift					}

sub new {
	my $class = shift;
	my %par = @_;
	my  ($context, $sync, $layouter, $rule_checker, $ok_hook) =
	@par{'context','sync','layouter','rule_checker','ok_hook'};

	my $self = $class->SUPER::new(@_);

	$sync           = 1 unless defined $sync;
	$context      ||= Gtk2::Ex::FormFactory::Context->new;
	$layouter     ||= Gtk2::Ex::FormFactory::Layout->new;
	$rule_checker ||= Gtk2::Ex::FormFactory::Rules->new;

	$self->set_context         ($context);
	$self->set_sync	           ($sync);
	$self->set_layouter        ($layouter);
	$self->set_rule_checker    ($rule_checker);
	$self->set_ok_hook	   ($ok_hook);
	$self->set_gtk_size_groups ({});

	return $self;
}

sub cleanup {
	my $self = shift;
	
	$self->SUPER::cleanup(@_);
	
	$self->set_gtk_size_groups({});

	1;
}

sub open {
	my $self = shift;
	
	#-- First build all widgets as implemented in the Widget class
	$self->build();
	
	#-- Now show all widgets
	foreach my $child ( @{$self->get_content} ) {
		$child->get_gtk_parent_widget->show_all;
	}
	
	#-- And finally connect the changed signals - this need to be
	#-- done *after* showing the widgets. For containers ->show()
	#-- could trigger updates which cause object updates. Since
	#-- ->update() isn't called yet, this would invalidate the 
	#-- object's state.
	$self->connect_signals;
	
	1;
}

sub update {
	my $self = shift;
	$self->update_all;
}

sub ok {
	my $self = shift;

	$self->apply_changes if not $self->get_sync;
	$self->close;
	
	1;
}

sub apply {
	my $self = shift;

	$self->apply_changes_all;

	1;
}

sub cancel {
	my $self = shift;
	
	$self->close;
	
	1;
}

sub close {
	my $self = shift;

	$_->get_gtk_parent_widget->destroy for @{$self->get_content};

	$self->cleanup;

	1;
}

1;

__END__

=head1 NAME

Gtk2::Ex::FormFactory - Makes building complex GUI's easy

=head1 SYNOPSIS

  #-- Refer to http://www.exit1.org/ for 
  #-- a comprehensive online documentation.

  #-- Read Gtk2::Ex::FormFactory::Intro

  use Gtk2::Ex::FormFactory;

  my $context  = Gtk2::Ex::FormFactory::Context->new;
  
  $context->add_object (
    name   => "worksheet",
    object => My::Worksheet->new,
  );
  
  # derived from Gtk2::Ex::FormFactory::Layout
  my $layouter = My::Layout->new;

  # derived from Gtk2::Ex::FormFactory::Rules
  my $rule_checker = My::Rules->new;

  my $ff = Gtk2::Ex::FormFactory->new (
    context      => $context,
    layouter     => $layouter,
    rule_checker => $rule_checker,
    content      => [
      Gtk2::Ex::FormFactory::Window->new (
        title   => "Worksheet Editor",
	content => [
	  Gtk2::Ex::FormFactory::Form->new (
	    title   => "Main data",
	    content => [
	      Gtk2::Ex::FormFactory::Entry->new (
		label => "Worksheet title",
		attr  => "worksheet.title",
		tip   => "Title of this worksheet",
	      ),
	      #-- More widgets...
	    ],
	  ),
	  Gtk2::Ex::FormFactory->DialogButtons->new,
	],
      ),
    ],
  );

  $ff->build;
  $ff->update;
  
  Gtk2->main;

=head1 ABSTRACT

With Gtk2::Ex::FormFactory you can build a GUI which consistently
represents the data of your application.

=head1 DESCRIPTION

This is a framework which tries to make building complex GUI's easy, by
offering these two main features:

  * Consistent looking GUI without the need to code resp. tune
    each widget by hand. Instead you declare the structure of your
    GUI, connect it to the data of your program (which should be
    a well defined set of objects) and control how this structure
    is transformed into a specific layout in a very generic way.

  * Automatically keep widget and object states in sync (in both
    directions), even with complex data structures with a lot of
    internal dependencies, object nesting etc.

This manpage describes the facilities of Gtk2::Ex::FormFactory objects
which are only a small part of the whole framework. To get a full
introduction and overview of how this framework works refer to
Gtk2::Ex::FormFactory::Intro.

=head1 OBJECT HIERARCHY

  Gtk2::Ex::FormFactory::Widget
  +--- Gtk2::Ex::FormFactory::Container
       +--- Gtk2::Ex::FormFactory

=head1 ATTRIBUTES

Attributes are handled through the common get_ATTR(), set_ATTR()
style accessors, but they are mostly passed once to the object
constructor and must not be altered after the associated FormFactory
was built.

=over 4

=item B<context> = Gtk2::Ex::FormFactory::Context [optional]

This is the Context of this FormFactory. The Context connects
your application objects and their attributes with the GUI
build through the FormFactory. Refer to
Gtk2::Ex::FormFactory::Context for details.

If you omit this option in the new() object constructor an
empty Context is created which can be accessed with
B<get_context>.

=item B<layouter> = Gtk2::Ex::FormFactory::Layout [optional]

This is the Layout module of this FormFactory. The Layout module
actually builds the GUI and thus controls all details of appearance.
Refer to Gtk2::Ex::FormFactory::Layout for details, if you're
interested in writing your own Layout module.

If you omit this option in the new() object constructor a
default Gtk2::Ex::FormFactory::Layout object is created which
can be accessed with B<get_layouter>.

=item B<rule_checker> = Gtk2::Ex::FormFactory::Rules [optional]

This is the rule checker module of this FormFactory. It's responsible
to check user input against a set of rules which may be associated
with a widget.

Refer to Gtk2::Ex::FormFactory::Rules for details, if you're
interested in writing your own rule checker module.

If you omit this option in the new() object constructor a
default Gtk2::Ex::FormFactory::Rules object is created which
can be accessed with B<get_rule_checker>.

=item B<sync> = BOOL [optional]

By default all changes on the GUI trigger corresopndent updates
on your application objects immediately. If you want to build
dialogs with local changes on the GUI only, e.g. to be able
to implement a Cancel button in a simple fashion (refer to
Gtk2::Ex::FormFactory::DialogButtons), you may switch this
synchronisation off by setting B<sync> to FALSE.

But note that asynchronous dialogs are static. Dependencies between
objects and attributes, which are defined in the associated
Gtk2::Ex::FormFactory::Context, don't work on widget/GUI level. That's
why automatic dependency resolution / widget updating only works
for FormFactory's with B<sync> set to TRUE.

=back

=head1 METHODS

=over 4

=item $form_factory->B<open> ()

This actually builds and displays the GUI. Until this method is called you
can add new or modify existent Widgets of this FormFactory.

No object data will be transfered to the GUI, so it will be
more or less empty. Call B<update> to put data into the GUI.

=item $form_factory->B<update> ()

After building the GUI you should call B<update> to transfer
your application data to the GUI.

=item $form_factory->B<ok> ()

This method applies all changes of a asynchronous FormFactory
and closes it afterwards.

=item $form_factory->B<apply> ()

All changes to Widgets inside this FormFactory are applied to the
associated application object attributes.

Useful only in a FormFactory with B<sync>=FALSE.

=item $form_factory->B<close> ()

When you exit the program you B<must> call B<close> on all FormFactories
which are actually open. Otherwise you will get error messages like
this from Perl's garbage collector:

  Attempt to free unreferenced scalar: SV 0x85d7374
    during global destruction.

That's because circular references are necessary between
Gtk2 and Gtk2::Ex::FormFactory widgets. These references
need first to be deleted until Perl can exit the program cleanly.

=item $form_factory->B<cancel>

Currently this simply calls $form_factory->B<close>.

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
