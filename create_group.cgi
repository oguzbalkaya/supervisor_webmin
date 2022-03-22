#! /usr/bin/perl
require './supervisor-lib.pl';
&ReadParse();
&ui_print_header(undef, $text{'create_group_title'},"");


print &ui_form_start('save_group.cgi');

print "$text{'create_group_required'}<br>";
print "$text{'create_group_emptyinfo'}<br>";
print &ui_hr();
print &ui_columns_start([
		$text{'create_group_key'},
		$text{'create_group_value'},
	]);
print &ui_columns_row([ "$text{'create_group_name'} <i style='color:red;'>*</i>" , &ui_textbox("group_name","") ]);
print &ui_columns_row([ "$text{'create_group_programs'} <i style='color:red;'>*</i>" , &ui_textbox("programs","") ]);
print &ui_columns_row([ $text{'create_group_priority'} , &ui_textbox("priority","") ]);
print &ui_columns_end();

print &ui_submit($text{'create_group_save'});
print &ui_form_end();

&ui_print_footer("", $text{'return_index'});
