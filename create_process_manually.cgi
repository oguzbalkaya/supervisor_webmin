#! /usr/bin/perl
require './supervisor-lib.pl';
&ReadParse();
&ui_print_header(undef, $text{'create_processmanually_title'},"");




print &ui_form_start('save_process_manually.cgi');

print &ui_columns_start();


if($config{'subprocess_files_path'} eq "")
{
	print &text("create_subprocessmanually_fileinfo",$config{'supervisor_conf'},"@{[&get_webprefix()]}/config.cgi?$module_name");
	
	#buraya bir hidden ekle.File name gelsin.EĞer path kısmı yazılmamışsa zaten gereksiz.
}
else
{
	print &ui_columns_row([ $text{'create_processmanually_filename'},"$config{'subprocess_files_path'}".&ui_textbox("file_name","").".conf" ]);
}
print &ui_columns_row([ $text{'create_processmanually_filecontent'} ,  &ui_textarea("data", "", 20,80)]);

print &ui_columns_end();

print &ui_submit($text{'create_process_save'});
print &ui_form_end();

&ui_print_footer("", $text{'return_index'});
