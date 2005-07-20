package Gtk2::Ex::FormFactory::Loader;

use strict;

@Gtk2::Ex::FormFactory::Button::ISA		= qw( Gtk2::Ex::FormFactory::Loader );
@Gtk2::Ex::FormFactory::CheckButtonGroup::ISA	= qw( Gtk2::Ex::FormFactory::Loader );
@Gtk2::Ex::FormFactory::CheckButton::ISA	= qw( Gtk2::Ex::FormFactory::Loader );
@Gtk2::Ex::FormFactory::Combo::ISA		= qw( Gtk2::Ex::FormFactory::Loader );
@Gtk2::Ex::FormFactory::DialogButtons::ISA	= qw( Gtk2::Ex::FormFactory::Loader );
@Gtk2::Ex::FormFactory::Entry::ISA		= qw( Gtk2::Ex::FormFactory::Loader );
@Gtk2::Ex::FormFactory::Expander::ISA 		= qw( Gtk2::Ex::FormFactory::Loader );
@Gtk2::Ex::FormFactory::Form::ISA 		= qw( Gtk2::Ex::FormFactory::Loader );
@Gtk2::Ex::FormFactory::GtkWidget::ISA 		= qw( Gtk2::Ex::FormFactory::Loader );
@Gtk2::Ex::FormFactory::HBox::ISA 		= qw( Gtk2::Ex::FormFactory::Loader );
@Gtk2::Ex::FormFactory::HSeparator::ISA 	= qw( Gtk2::Ex::FormFactory::Loader );
@Gtk2::Ex::FormFactory::Image::ISA 		= qw( Gtk2::Ex::FormFactory::Loader );
@Gtk2::Ex::FormFactory::Label::ISA 		= qw( Gtk2::Ex::FormFactory::Loader );
@Gtk2::Ex::FormFactory::List::ISA 		= qw( Gtk2::Ex::FormFactory::Loader );
@Gtk2::Ex::FormFactory::Menu::ISA 		= qw( Gtk2::Ex::FormFactory::Loader );
@Gtk2::Ex::FormFactory::Notebook::ISA 		= qw( Gtk2::Ex::FormFactory::Loader );
@Gtk2::Ex::FormFactory::Popup::ISA 		= qw( Gtk2::Ex::FormFactory::Loader );
@Gtk2::Ex::FormFactory::ProgressBar::ISA 	= qw( Gtk2::Ex::FormFactory::Loader );
@Gtk2::Ex::FormFactory::RadioButton::ISA 	= qw( Gtk2::Ex::FormFactory::Loader );
@Gtk2::Ex::FormFactory::Table::ISA 		= qw( Gtk2::Ex::FormFactory::Loader );
@Gtk2::Ex::FormFactory::TextView::ISA 		= qw( Gtk2::Ex::FormFactory::Loader );
@Gtk2::Ex::FormFactory::Timestamp::ISA 		= qw( Gtk2::Ex::FormFactory::Loader );
@Gtk2::Ex::FormFactory::ToggleButton::ISA 	= qw( Gtk2::Ex::FormFactory::Loader );
@Gtk2::Ex::FormFactory::VBox::ISA 		= qw( Gtk2::Ex::FormFactory::Loader );
@Gtk2::Ex::FormFactory::VSeparator::ISA 	= qw( Gtk2::Ex::FormFactory::Loader );
@Gtk2::Ex::FormFactory::Window::ISA 		= qw( Gtk2::Ex::FormFactory::Loader );
@Gtk2::Ex::FormFactory::YesNo::ISA 		= qw( Gtk2::Ex::FormFactory::Loader );

sub new {
	my $class = shift;
	eval "use $class; shift \@$class:\:ISA";
	if ( $@ ) {
		print $@;
		exit;
	}
	return $class->new(@_);
}

1;
