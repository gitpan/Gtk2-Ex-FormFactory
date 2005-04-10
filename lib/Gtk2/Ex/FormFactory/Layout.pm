package Gtk2::Ex::FormFactory::Layout;

use strict;

use Gtk2::SimpleList;
use Gtk2::SimpleMenu;

sub new {
	my $class = shift;
	
	return bless {}, $class;
}

sub build_widget {
	my $self = shift;
	my ($widget) = @_;

	return if $widget->get_type eq 'form_factory';

	if ( $widget->can("build_widget") ) {
		$widget->build_widget;
	} else {
		my $widget_type = $widget->get_type;
		my $method      = "build_$widget_type";
	
		$Gtk2::Ex::FormFactory::DEBUG &&
		    print "build_widget: ".$widget->get_type.
		      "(".$widget->get_name.")\n";

		$self->$method($widget);
	}

	if ( $widget->get_properties ) {
		$widget->get_gtk_properties_widget->set (
		  %{$widget->get_properties}
		);
	}

	if ( $widget->get_width or $widget->get_height ) {
		$widget->get_gtk_widget->set_size_request (
			($widget->get_width||-1),
			($widget->get_height||-1),
		);
	}

	if ( $widget->get_customize_hook ) {
		my $cb = $widget->get_customize_hook;
		&$cb($widget->get_gtk_widget);
	}

	my $tip = !$widget->isa_container ? $widget->get_tip : "";
	if ( $tip ) {
		$tip .= "." if $tip !~ /\.\s*$/;
		my $gtk_tip = Gtk2::Tooltips->new;
		for ( @{$widget->get_gtk_tip_widgets} ) {
			$gtk_tip->set_tip ($_, $tip, undef);
		}
	}		

	my $scrollbars = $widget->get_scrollbars;
	if ( $scrollbars ) {
		my $sw = Gtk2::ScrolledWindow->new;
		$sw->add($widget->get_gtk_parent_widget);
		$sw->set_policy(@{$scrollbars});
		$widget->set_gtk_parent_widget($sw);
	}

	if ( $widget->get_gtk_widget and
	     $widget->get_widget_group ) {
		my $group = $widget->get_widget_group;
		my $gtk_size_group =
		    $widget->get_form_factory
			   ->get_gtk_size_groups->{$group} ||=
			Gtk2::SizeGroup->new("horizontal");
		$gtk_size_group->add_widget ($widget->get_gtk_widget);
	}

	1;
}

sub add_widget_to_container {
	my $self = shift;
	my ($widget, $container) = @_;

	return if $container->get_type eq 'form_factory';

	my $container_type = $container->get_type;
	my $widget_type    = $widget->get_type;

	my $method = "add_".$widget_type."_to_".$container_type;

	if ( not $self->can($method) ) {
		$widget_type = "widget";
		$method      = "add_".$widget_type."_to_".$container_type;
	}

	$Gtk2::Ex::FormFactory::DEBUG &&
	    print "add widget: ".
	      $container->get_type.
	      "(".$container->get_name.") + ".
	      $widget->get_type.
	      "(".$widget->get_name.")\n";

	$self->$method($widget, $container);

	if ( $widget->get_gtk_label_widget and
	     $widget->get_label_group ) {
		my $group = $widget->get_label_group;
		my $gtk_size_group =
		    $widget->get_form_factory
			   ->get_gtk_size_groups->{$group} ||=
			Gtk2::SizeGroup->new("horizontal");
		$gtk_size_group->add_widget ($widget->get_gtk_label_widget);
	}

	1;
}

sub create_label_widget {
	my $self = shift;
	my ($widget) = @_;
	
	my $gtk_label;
	if ( $widget->get_label_markup ) {
		$gtk_label = Gtk2::Label->new;
		$gtk_label->set_markup($widget->get_label);
	} else {
		$gtk_label = Gtk2::Label->new($widget->get_label);
	}
	$gtk_label->set ( yalign => 0.5, xalign => 0 );

	return $gtk_label;
}

sub create_bold_label_widget {
	my $self = shift;
	my ($label_text) = @_;
	
	my $gtk_label = Gtk2::Label->new;
	$gtk_label->set ( yalign => 0.5, xalign => 0 );
	$label_text =~ s/&/&amp;/g;
	$label_text =~ s/</&lt;/g;
	$gtk_label->set_markup("<b>$label_text </b>");

	return $gtk_label;
}

sub build_window {
	my $self = shift;
	my ($window) = @_;
	
	my $gtk_window = Gtk2::Window->new;
	$gtk_window->set_title($window->get_title);
	$gtk_window->set_position('center');

	my $vbox = Gtk2::VBox->new(0, 5);
	$vbox->set ( border_width => 5 );
	$gtk_window->add($vbox);
	
	$window->set_gtk_widget($vbox);
	$window->set_gtk_parent_widget($gtk_window);
	$window->set_gtk_properties_widget($gtk_window);
	
	my $closed_hook = $window->get_closed_hook;

	if ( $closed_hook ) {
		$gtk_window->signal_connect (
			destroy => $closed_hook
		);
	}
	
	if ( $window->get_parent->isa("Gtk2::Ex::FormFactory") ) {
		$gtk_window->signal_connect (
			destroy => sub {
				#-- Close FormFactory. If no FormFactory
				#-- is set, cleanup() was already called.
				$window->get_form_factory->close
					if $window->get_form_factory;
				1;
			},
		);
	}

	if ( $window->get_form_factory->get_parent_ff ) {
		my $gtk_parent_window =
			$window->get_form_factory
			       ->get_parent_ff
			       ->get_form_factory_gtk_window;
		$gtk_window->set_transient_for($gtk_parent_window);
	}

	1;
}

sub build_menu {
	my $self = shift;
	my ($menu) = @_;
	
	my $gtk_menu = Gtk2::SimpleMenu->new (
		menu_tree        => $menu->get_menu_tree,
		default_callback => $menu->get_default_callback,
		user_data	 => $menu->get_user_data,
	);
	
	$menu->set_gtk_widget($gtk_menu->{widget});
	$menu->set_gtk_simple_menu($gtk_menu);
	
	1;
}

sub build_notebook {
	my $self = shift;
	my ($notebook) = @_;
	
	my $gtk_notebook = Gtk2::Notebook->new;

	$notebook->set_gtk_widget($gtk_notebook);

	1;
}

sub build_expander {
	my $self = shift;
	my ($expander) = @_;
	
	my $gtk_expander = Gtk2::Expander->new ($expander->get_label);
	
	$expander->set_gtk_widget($gtk_expander);
	
	1;
}

sub build_form {
	my $self = shift;
	my ($form) = @_;
	
	my $child_cnt = @{$form->get_content};
	my $title     = $form->get_title;
	
	my $frame;
	my $table = Gtk2::Table->new($child_cnt, 2);
	$table->set ( row_spacing => 2, column_spacing => 10 );

	if ( $title ) {
		my $gtk_label = $self->create_bold_label_widget($title);
		$frame = Gtk2::Frame->new;
		$frame->set_label_widget($gtk_label);
		$frame->add($table);
		$table->set ( border_width => 5 );
	}

	$form->set_gtk_widget($table);
	$form->set_gtk_parent_widget($frame);
	
	1;
}

sub build_form_label_right {
	shift->build_form(@_);
}

sub build_table {
	my $self = shift;
	my ($table) = @_;
	
	my $title = $table->get_title;
	
	my $gtk_frame;
	my $gtk_table = Gtk2::Table->new($table->get_rows, $table->get_columns);
	$gtk_table->set ( row_spacing => 2, column_spacing => 2 );

	if ( $title ) {
		my $gtk_label = $self->create_bold_label_widget($title);
		$gtk_frame = Gtk2::Frame->new;
		$gtk_frame->set_label_widget($gtk_label);
		$gtk_frame->add($gtk_table);
		$gtk_table->set ( border_width => 5 );
	}

	$table->set_gtk_widget($gtk_table);
	$table->set_gtk_parent_widget($gtk_frame);
	
	my $layout_widget_cnt  = @{$table->get_widget_table_attach};
	my $content_widget_cnt = @{$table->get_content};

	if ( $layout_widget_cnt != $content_widget_cnt ) {
		die "Table ".$table->get_name.": layout defines ".
		    "$layout_widget_cnt widgets, but the table contains ".
		    "$content_widget_cnt widgets";
	}
	
	1;
}

sub build_vbox {
	my $self = shift;
	my ($vbox) = @_;

	my $title = $vbox->get_title;
	
	my $frame;
	my $gtk_vbox = Gtk2::VBox->new($vbox->get_homogenous,($vbox->get_spacing||5));
	
	if ( $title and not $vbox->get_no_frame ) {
		my $gtk_label = $self->create_bold_label_widget($title);
		$frame = Gtk2::Frame->new;
		$frame->set_label_widget($gtk_label);
		$frame->add($gtk_vbox);
		$gtk_vbox->set ( border_width => 5 );
	}

	$vbox->set_gtk_widget($gtk_vbox);
	$vbox->set_gtk_parent_widget($frame);
	
	1;
}

sub build_hbox {
	my $self = shift;
	my ($hbox) = @_;

	my $title = $hbox->get_title;

	my $frame;
	my $gtk_hbox = Gtk2::HBox->new($hbox->get_homogenous,($hbox->get_spacing||5));
	
	if ( $title and not $hbox->get_no_frame ) {
		my $gtk_label = $self->create_bold_label_widget($title);
		$frame = Gtk2::Frame->new;
		$frame->set_label_widget($gtk_label);
		$frame->add($gtk_hbox);
		$gtk_hbox->set ( border_width => 5 );
	}

	$hbox->set_gtk_widget($gtk_hbox);
	$hbox->set_gtk_parent_widget($frame);
	
	1;
}

sub build_label {
	my $self = shift;
	my ($label) = @_;
	
	my $gtk_label = Gtk2::Label->new;
	$gtk_label->set_text   ($label->get_label) if $label->get_label;
	$gtk_label->set_markup ($label->get_label) if $label->get_with_markup;

	$gtk_label->set ( xalign => 0, yalign => 0.5 );

	$label->set_gtk_widget($gtk_label);
	
	1;
}

sub build_hseparator {
	my $self = shift;
	my ($hseparator) = @_;
	
	my $gtk_sep = Gtk2::HSeparator->new;
	$gtk_sep->set ( height_request => 10 );

	$hseparator->set_gtk_widget($gtk_sep);
	
	1;
}

sub build_vseparator {
	my $self = shift;
	my ($vseparator) = @_;
	
	my $gtk_sep = Gtk2::VSeparator->new;
	$gtk_sep->set ( width_request => 10 );

	$vseparator->set_gtk_widget($gtk_sep);
	
	1;
}

sub build_entry {
	my $self = shift;
	my ($entry) = @_;
	
	my $gtk_entry = Gtk2::Entry->new;
	
	$entry->set_gtk_widget($gtk_entry);
	
	1;
}

sub build_combo {
	my $self = shift;
	my ($combo) = @_;
	
	my $gtk_combo = Gtk2::Combo->new;
	$combo->set_gtk_widget($gtk_combo);

	1;
}

sub build_toggle_button {
	my $self = shift;
	my ($toggle_button) = @_;
	
	my $hbox = Gtk2::HBox->new;
	$toggle_button->set_gtk_parent_widget($hbox);

	my $gtk_toggle_button = Gtk2::ToggleButton->new_with_label("");
	$toggle_button->set_gtk_widget($gtk_toggle_button);

	$hbox->pack_start($gtk_toggle_button, 0, 1, 0);

	1;
}

sub build_check_button {
	my $self = shift;
	my ($check_button) = @_;
	
	my $gtk_check_button = Gtk2::CheckButton->new;
	$gtk_check_button->set_label($check_button->get_label)
		if $check_button->has_label;
	$check_button->set_gtk_widget($gtk_check_button);
	
	1;
}

sub build_yesno {
	my $self = shift;
	my ($yesno) = @_;
	
	my $gtk_yes_radio = Gtk2::RadioButton->new_with_label(
		undef,
		$yesno->get_true_label
	);

	my $gtk_no_radio = Gtk2::RadioButton->new_with_label(
		$gtk_yes_radio->get_group,
		$yesno->get_false_label
	);

	my $hbox = Gtk2::HBox->new;

	$hbox->pack_start($gtk_yes_radio, 0, 1, 0);
	$hbox->pack_start($gtk_no_radio,  0, 1, 0);

	$yesno->set_gtk_parent_widget($hbox);
	$yesno->set_gtk_widget($gtk_yes_radio);
	$yesno->set_gtk_yes_widget($gtk_yes_radio);
	$yesno->set_gtk_no_widget($gtk_no_radio);

	1;
}

sub build_radio_button {
	my $self = shift;
	my ($radio_button) = @_;
	
	my $group_name = $radio_button->get_object.".".
			 $radio_button->get_attr;

	my $gtk_radio_group = $radio_button->get_parent->{_radio_group}->{$group_name};
	
	my $gtk_radio_button = Gtk2::RadioButton->new_with_label(
		$gtk_radio_group,
		$radio_button->get_label
	);

	$radio_button->get_parent->{_radio_group}->{$group_name}
		||= $gtk_radio_button->get_group;

	$radio_button->set_gtk_widget($gtk_radio_button);
	
	1;
}

sub build_button {
	my $self = shift;
	my ($button) = @_;

	my $stock = $button->get_stock;
	my $label = $button->get_label;

	my $gtk_button;
	
	if ( $stock and $label ) {
		my $hbox = Gtk2::HBox->new;
		my $image = Gtk2::Image->new_from_stock($stock,"button");
		my $label = Gtk2::Label->new($label);
		$hbox->pack_start($image, 0, 1, 0);
		$hbox->pack_start($label, 0, 1, 0);
		$gtk_button = Gtk2::Button->new;
		$gtk_button->add($hbox);
	} elsif ( $stock and not $label ) {
		$gtk_button = Gtk2::Button->new_from_stock($stock);
	} else {
		$gtk_button = Gtk2::Button->new($label);
	}

	$button->set_gtk_widget($gtk_button);
	
	my $clicked_hook = $button->get_clicked_hook;
	
	$gtk_button->signal_connect ( clicked => $clicked_hook )
		if $clicked_hook;
	
	1;
}

sub build_list {
	my $self = shift;
	my ($list) = @_;
	
	my $columns  = $list->get_columns;
	my $types    = $list->get_types;
	my $editable = $list->get_editable;
	
	my (@slist, $i);

	foreach my $col ( @{$columns} ) {
		push @slist, $col, ($types->[$i]||"text");
		++$i;
	}

	my $slist = Gtk2::SimpleList->new ( @slist );

	if ( $editable ) {
		$i = 0;
		foreach my $e ( @{$editable} ) {
			$slist->set_column_editable($i, $e);
			++$i;
		}
	}

	$slist->get_selection->set_mode ($list->get_selection_mode)
		if $list->get_selection_mode;

	$list->set_gtk_widget($slist);
	
	1;
}

sub build_popup {
	my $self = shift;
	my ($popup) = @_;
	
	my $gtk_popup_menu = Gtk2::Menu->new;
	my $gtk_popup = Gtk2::OptionMenu->new;
	$gtk_popup->set_menu($gtk_popup_menu);

	$popup->set_gtk_widget ( $gtk_popup );

	1;	
}

sub build_progress_bar {
	my $self = shift;
	my ($progress_bar) = @_;
	
	my $gtk_progress_bar = Gtk2::ProgressBar->new;
	
	$progress_bar->set_gtk_widget($gtk_progress_bar);
	
	1;
}

sub build_image {
	my $self = shift;
	my ($image) = @_;

	my $gtk_image = Gtk2::Image->new;
	$gtk_image->set_size_request(undef, undef);
	$image->set_gtk_widget($gtk_image);

	my $bgcolor = $image->get_bgcolor;
	my $gtk_event_box = Gtk2::EventBox->new;
	$gtk_event_box->modify_bg ("normal", Gtk2::Gdk::Color->parse ($bgcolor))
		if defined $bgcolor;
	$gtk_event_box->add($gtk_image);

	$image->set_gtk_event_box($gtk_event_box);

	if ( $image->get_with_frame ) {
		my $gtk_frame = Gtk2::Frame->new;
		$gtk_frame->add($gtk_event_box);
		$image->set_gtk_parent_widget($gtk_frame);
	} else {
		$image->set_gtk_parent_widget($gtk_event_box);
	}

	my $update_timeout;
	if ( $image->get_scale_to_fit or
	     $image->get_max_width or
	     $image->get_max_height ) {
		$gtk_event_box->signal_connect (
		    "size-allocate" => sub {
			return if $image->get_widget_width  == $_[1]->width and
				  $image->get_widget_height == $_[1]->height;
			$image->set_widget_width($_[1]->width);
			$image->set_widget_height($_[1]->height);
			Glib::Source->remove($update_timeout)
				if $update_timeout;
			$update_timeout = Glib::Timeout->add (
				100, sub {
					$image->update;
					$update_timeout = undef;
					0
				}
			);
			0;
		    }
		);
	}
	
	1;
}

sub build_dialog_buttons {
	my $self = shift;
	my ($dialog_buttons) = @_;
	
	my ($button_box, $button);
	$button_box = Gtk2::HButtonBox->new;
	$button_box->set (
	  layout_style => "end",
	  spacing      => 10,
	);

	my $buttons = $dialog_buttons->get_buttons;

	if ( not $dialog_buttons->get_form_factory->get_sync ) {
		if ( $buttons->{cancel} ) {
		    $button = Gtk2::Button->new_from_stock("gtk-cancel");
		    $button->show;
		    $button_box->pack_start($button, 0, 1, 0);
		    $button->signal_connect (
			clicked => sub {
		            my $clicked_hook_before = $dialog_buttons->get_clicked_hook_before;
		            my $clicked_hook_after  = $dialog_buttons->get_clicked_hook_after;
			    my $default_handler = 1;
			    $default_handler = &$clicked_hook_before("cancel")
				    if $clicked_hook_before;
			    return if not $default_handler;
		    	    $dialog_buttons->get_form_factory->cancel;
			    &$clicked_hook_after("cancel")
				    if $clicked_hook_after;
			},
		    );
		    $dialog_buttons->set_gtk_cancel_button($button);
		}

		if ( $buttons->{apply} ) {
		    $button = Gtk2::Button->new_from_stock("gtk-apply");
		    $button->show;
		    $button_box->pack_start($button, 0, 1, 0);
		    $button->signal_connect (
			clicked => sub {
		            my $clicked_hook_before = $dialog_buttons->get_clicked_hook_before;
		            my $clicked_hook_after  = $dialog_buttons->get_clicked_hook_after;
			    my $default_handler = 1;
			    $default_handler = &$clicked_hook_before("apply")
				    if $clicked_hook_before;
			    return if not $default_handler;
		    	    $dialog_buttons->get_form_factory->apply;
			    &$clicked_hook_after("apply")
				    if $clicked_hook_after;
			},
		    );
		    $dialog_buttons->set_gtk_apply_button($button);
		}
	}

	if ( $buttons->{ok} ) {
	    $button = Gtk2::Button->new_from_stock("gtk-ok");
	    $button->show;
	    $button_box->pack_start($button, 0, 1, 0);
	    $button->signal_connect (
		clicked => sub {
		    my $clicked_hook_before = $dialog_buttons->get_clicked_hook_before;
		    my $clicked_hook_after  = $dialog_buttons->get_clicked_hook_after;
		    my $default_handler = 1;
		    $default_handler = &$clicked_hook_before("ok")
			    if $clicked_hook_before;
		    return if not $default_handler;
		    $dialog_buttons->get_form_factory->ok;
		    &$clicked_hook_after("ok")
			    if $clicked_hook_after;
		},
	    );
	    $dialog_buttons->set_gtk_ok_button($button);
	}

	$dialog_buttons->set_gtk_widget($button_box);

	1;
}

sub build_timestamp {
	my $self = shift;
	my ($timestamp) = @_;
	
	my $hbox  = Gtk2::HBox->new;

	my $mday  = Gtk2::Entry->new;
	my $mon   = Gtk2::Entry->new;
	my $year  = Gtk2::Entry->new;
	my $hour  = Gtk2::Entry->new;
	my $min   = Gtk2::Entry->new;

	$mday->set ( width_chars => 2, max_length  => 2 );
	$mon->set  ( width_chars => 2, max_length  => 2 );
	$year->set ( width_chars => 4, max_length  => 4 );
	$hour->set ( width_chars => 2, max_length  => 2 );
	$min->set  ( width_chars => 2, max_length  => 2 );

	$timestamp->set_gtk_widget($hbox);
	$timestamp->set_gtk_mday_widget($mday);
	$timestamp->set_gtk_mon_widget($mon);
	$timestamp->set_gtk_year_widget($year);
	$timestamp->set_gtk_hour_widget($hour);
	$timestamp->set_gtk_min_widget($min);

	my $format = $timestamp->get_format;

	while ( $format =~ /([^%]*)%(.)/g ) {
		my $text = $1;
		my $dfmt = $2;

		if ( $text ) {
			$hbox->pack_start(Gtk2::Label->new($text), 0, 1, 0);
		}
		if ( $dfmt eq 'd' ) {
			$hbox->pack_start ($mday, 0, 1, 0);
		} elsif ( $dfmt eq 'm' ) {
			$hbox->pack_start ($mon,  0, 1, 0);
		} elsif ( $dfmt eq 'Y' ) {
			$hbox->pack_start ($year, 0, 1, 0);
		} elsif ( $dfmt eq 'k' ) {
			$hbox->pack_start ($hour, 0, 1, 0);
		} elsif ( $dfmt eq 'M' ) {
			$hbox->pack_start ($min,  0, 1, 0);
		} else {
			warn "Unknown timestamp format \%$dfmt ignored";
		}
	}

	1;
}

sub build_gtk_widget {
	my $self = shift;
	my ($gtk_widget) = @_;
	
	$gtk_widget->set_gtk_parent_widget($gtk_widget->get_custom_gtk_widget);
	
	1;
}

sub build_check_button_group {
	my $self = shift;
	my ($check_button_group) = @_;

	my $hbox = Gtk2::HBox->new;
	
	$check_button_group->set_gtk_widget($hbox);

	1;
}

sub build_text_view {
	my $self = shift;
	my ($text_view) = @_;
	
	my $gtk_text_view = Gtk2::TextView->new;
	
	$text_view->set_gtk_widget($gtk_text_view);
	
	1;
}

sub add_widget_to_form {
	my $self = shift;
	my ($widget, $form) = @_;
	
	my $row        = $form->get_layout_data->{row} || 0;
	my $gtk_table  = $form->get_gtk_widget;
	my $gtk_widget = $widget->get_gtk_parent_widget;
	
	my $xopt = $widget->get_expand_h ? ['fill','expand'] : ['fill'];
	my $yopt = $widget->get_expand_v ? ['fill','expand'] : ['fill'];

	if ( $widget->get_label ne '' and not $widget->has_label ) {
		my $gtk_label = $self->create_label_widget ($widget);
		$gtk_table->attach($gtk_label, 0, 1, $row, $row+1, 'fill', 'fill', 0, 0);
		$widget->set_gtk_label_widget ($gtk_label);
	}

	if ( not $widget->get_expand_h ) {
		my $hbox = Gtk2::HBox->new;
		$hbox->pack_start($gtk_widget, 0, 1, 0);
		$gtk_widget = $hbox;
	}

	$gtk_table->attach($gtk_widget, 1, 2, $row, $row+1, $xopt, $yopt, 0, 0);
	
	$form->get_layout_data->{row}++;
	
	1;
}

sub add_widget_to_form_label_right {
	my $self = shift;
	my ($widget, $form) = @_;
	
	my $row       = $form->get_layout_data->{row} || 0;
	my $gtk_table = $form->get_gtk_widget;
	my $gtk_entry = $widget->get_gtk_parent_widget;

	$gtk_table->attach_defaults($gtk_entry, 0, 1, $row, $row+1);

	if ( $widget->get_label ne '' and not $widget->has_label ) {
		my $gtk_label = $self->create_label_widget ($widget);
		$gtk_table->attach($gtk_label, 1, 2, $row, $row+1, 'fill', [], 0, 0);
		$widget->set_gtk_label_widget ($gtk_label);
	}

	$form->get_layout_data->{row}++;
	
	1;
}

sub add_widget_to_table {
	my $self = shift;
	my ($widget, $table) = @_;
	
	my $child_idx = $table->get_layout_data->{child_idx} || 0;

	my $table_attach = $table->get_widget_table_attach->[$child_idx];

	$table->get_gtk_widget->attach(
		$table->get_content->[$child_idx]->get_gtk_parent_widget,
		@{$table_attach},
		0, 0
	);
	
	$table->get_layout_data->{child_idx}++;
	
	1;
}

sub add_widget_to_vbox {
	my $self = shift;
	my ($widget, $vbox) = @_;
	
	my $gtk_vbox   = $vbox->get_gtk_widget;
	my $gtk_widget = $widget->get_gtk_parent_widget;
	
	if ( $widget->get_label ne '' and not $widget->has_label ) {
		my $gtk_label = $self->create_label_widget ($widget);
		$gtk_vbox->pack_start($gtk_label,  0, 1, 0);
		$widget->set_gtk_label_widget ($gtk_label);
	}
	
	$gtk_vbox->pack_start($gtk_widget, $widget->get_expand, 1, 0);
	
	1;
}

sub add_widget_to_hbox {
	my $self = shift;
	my ($widget, $hbox) = @_;
	
	my $gtk_hbox   = $hbox->get_gtk_widget;
	my $gtk_widget = $widget->get_gtk_parent_widget;
	
	if ( $widget->get_label ne '' and not $widget->has_label ) {
		my $gtk_label = $self->create_label_widget ($widget);
		$gtk_hbox->pack_start($gtk_label,  0, 1, 0);
		$widget->set_gtk_label_widget ($gtk_label);
	}
	
	$gtk_hbox->pack_start($gtk_widget, $widget->get_expand, 1, 0);
	
	1;
}

sub add_widget_to_expander {
	my $self = shift;
	my ($widget, $expander) = @_;
	
	$expander->get_gtk_widget->add ($widget->get_gtk_parent_widget);
	
	1;
}

sub add_widget_to_notebook {
	my $self = shift;
	my ($widget, $notebook) = @_;
	
	$widget->get_gtk_parent_widget->set ( border_width => 5 );
	
	my $label = $widget->get_title ne '' ?
		Gtk2::Label->new($widget->get_title) :
		undef;
	
	$notebook->get_gtk_widget->append_page(
		$widget->get_gtk_parent_widget,
		$label
	);
	
	1;
}

sub add_widget_to_window {
	my $self = shift;
	my ($widget, $window) = @_;
	
	my $vbox = $window->get_gtk_widget;
	$vbox->pack_start(
		$widget->get_gtk_parent_widget,
		$widget->get_expand, 1, 0
	);

	1;
}

sub add_menu_to_window {
	my $self = shift;
	my ($menu, $window) = @_;

	my $gtk_window_vbox = $window->get_gtk_widget;
	my $gtk_window      = $window->get_gtk_parent_widget;
	my $gtk_menu_vbox   = Gtk2::VBox->new(0,0);

	$gtk_menu_vbox->pack_start($menu->get_gtk_parent_widget, 0, 1, 0);

	$gtk_window->remove($gtk_window_vbox);
	$gtk_window->add($gtk_menu_vbox);
	$gtk_menu_vbox->pack_start($gtk_window_vbox, 1, 1, 0);

	$gtk_window->add_accel_group(
		$menu->get_gtk_simple_menu->{accel_group}
	);

	1;
}

sub add_buttons_to_window {
	my $self = shift;
	my ($buttons, $window) = @_;
	
	my $vbox = $window->get_gtk_widget;
	$vbox->pack_start($buttons->get_gtk_parent_widget, 0, 1, 0);

	1;
}

1;


__END__

=head1 NAME

Gtk2::Ex::FormFactory::Layout - Do layout in a FormFactory framework

=head1 SYNOPSIS

  package My::Layout;

  use base qw/Gtk2::Ex::FormFactory::Layout/;

  sub build_form         { ... }
  sub add_widget_to_form { ... }
  ...

  package main;
  
  $ff = Gtk2::Ex::FormFactory->new (
    layouter => My::Layout->new(),
    ...
  );

=head1 DESCRIPTION

This class implements the layout of Containers and their Widgets
in a Gtk2::Ex::FormFactory framework. "Layout" means, how are
the widgets aligned to each other, how much space is between them,
how are titles rendered, how labels, etc.

The idea behind Gtk2::Ex::FormFactory::Layout is to have a unique
point in a GUI application which actually implements these things. The
advantage of this approach is obvious: the implementation is very
generic and if you want to change layout things you subclass from
Gtk2::Ex::FormFactory::Layout and implement your changes there,
and not at hundreds of spots distributed over the source code
of your application.

The natural result: a consistent looking GUI.

=head1 SUBCLASSING

As described above implementing your own layout module starts
with subclassing from Gtk2::Ex::FormFactory::Layout. To use
your layout implementation set an object of your class as
B<layouter> in your Gtk2::Ex::FormFactory objects.

Gtk2::Ex::FormFactory::Layout mainly defines two sorts of methods.

=head2 BUILD METHODS

The names of the methods are derived from the Widget's short names
(which can be retrieved with $widget->get_type), with a prepended
B<build_>, e.g.:

  build_form  ( ... )
  build_label ( ... )
  build_table ( ... )

The method prototype looks like this:

=over 4

=item $layout->B<build_TYPE> ($widget)

B<$widget> is the actual Gtk2::Ex::FormFactory::Widget, e.g.
Gtk2::Ex::FormFactory::Form for B<build_form>($form).

=back

The B<build_TYPE> method actually creates the necessary Gtk2 widgets,
e.g. a Gtk2::Table for a Gtk2::Ex::FormFactory::Form and adds
these to the FormFactory's widget instance using the B<set_gtk_widget>()
and B<set_gtk_parent_widget>() methods of Gtk2::Ex::FormFactory::Widget.

Call $widget->B<set_gtk_widget>($gtk_widget) for the primary Gtk2 widget
which directly displays the value in question, e.g. a Gtk2::Entry if you're
dealing with a Gtk2::Ex::FormFactory::Entry.

If you like to do more layout things which require to add the primary
Gtk2 widget to a container, e.g. a Gtk2::Frame, you must call 
$widget->B<set_gtk_parent_widget>($gtk_parent_widget) with the
most top level container widget.

B<Note:> the implemenations of all the FormFactory's widgets expect
a specific B<gtk_widget> to be set. If you like to change the primary
Gtk widget you need to create your own Gtk2::Ex::FormFactory::Widget
for this, because the default implemention most probably won't work
with a another Gtk2::Widget.

=head2 ADD...TO... METHODS

The second type of methods are so called add-to methods, which place
a widget inside a container. The prototye is as follows:

=over 4

=item $layout->B<add_TYPE_to_TYPE> ($widget, $container)

B<$widget> is the actual Gtk2::Ex::FormFactory::Widget, e.g.
Gtk2::Ex::FormFactory::Form for B<build_form>($form).

=back

Examples:

  add_form_to_window ( ... )
  add_table_to_form  ( ... )

This way you can adjust layout at a very detailed level, but
you need not. E.g. the implementation of these methods is
most likely the same:

  add_entry_to_form ( ... )
  add_popup_to_form ( ... )

because the implemenation mainly depends on the B<form>
(the container widget) and not on the widget which is added to
the form.

That's why Gtk2::Ex::FormFactory::Layout knows a default mechanism:
if no add-to method is found for a specific widget/container
pair, a generic default implementation is used instead. These
are named as follows:

  add_widget_to_window ( ... )
  add_widget_to_form   ( ... )
  add_widget_to_table  ( ... )
  add_widget_to_vbox   ( ... )
  ...

For a new Container you just need to implement the generic
B<add_widget_to_TYPE> method, and everything will work. If
you want to slightly modify the implementation for specific
child widgets, you implement only the methods for these and
you're done.

For a example for such a specific add-to message refer to
B<add_menu_to_window>() which attaches the menu without any
space around it. The default of a Gtk2::Ex::FormFactory::Window
is to have some spacing, which looks ugly around a menu.

=head1 OBJECT HIERARCHY

  Gtk2::Ex::FormFactory::Layout

=head1 ATTRIBUTES

This class has not attributes.

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