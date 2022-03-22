#!/usr/bin/perl

require './supervisor-lib.pl';
&ReadParse();
&ui_print_header(undef, $text{'edit_manual_title'},"");

my @files = ( $config{'supervisor_conf'} );

$in{"file"} ||= $files[0];
&indexof($in{'file'}, @files) >= 0 || &error($text{'edit_manual_errorfile'});
print &ui_form_start("edit_manual.cgi");
print &ui_select("file", $in{'file'},
                        [ map { [ $_ ] } @files ]),"\n";
print &ui_submit($text{'edit_manual_ok'});
print &ui_form_end();


print &ui_form_start("save_manual.cgi", "form-data");
print &ui_hidden("file", $in{'file'}),"\n";
my $data = &read_file_contents($in{'file'});
print &ui_textarea("data", $data, 20,80),"\n";
print &ui_form_end([ [ "save", $text{'edit_manual_save'} ] ]);

&ui_print_footer("", $text{'return_index'});

