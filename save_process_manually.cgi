#! /usr/bin/perl

require './supervisor-lib.pl';
&ReadParse();
&error($text{'create_processmanually_contentrequired'}) if(not $in{'data'} or $in{'data'} eq "");
&ui_print_header(undef, $text{'create_process_title'},"");


if($config{'subprocess_files_path'} eq "")
{
	&create_process_manually("",$in{'data'});
}
else
{
	&create_process_manually($in{'file_name'},$in{'data'});
	&error($text{'create_processmanually_filenamerequired'}) if(not $in{'file_name'} or $in{'file_name'} eq "");
}

if($config{'autorestart'} eq "1")
{
	print "<br>$text{'create_process_restartinfo'}";
}
else
{
	print "<br>$text{'create_process_norestartinfo'}";
}

&webmin_log($text{'create_processmanually_webminlog'}, undef, "file : $in{'file_name'}");
&ui_print_footer("", $text{'return_index'});
