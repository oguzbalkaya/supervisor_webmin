#! /usr/bin/perl

require './supervisor-lib.pl';
&ReadParse();
&ui_print_header(undef, $text{'create_process_title'},"");

&error($text{'create_process_namerequired'}) if(not $in{'process_name'} or $in{'process_name'} eq "");
&error($text{'create_process_command'}) if(not $in{'command'} or $in{'command'} eq "");
&create_process(\%in);



print "<i style='color:green;'>$text{'create_process_success'}</i>";

if($config{'autorestart'} eq "1")
{
	print "<br>$text{'create_process_restartinfo'}";
}
else
{
	print "<br>$text{'create_process_norestartinfo'}";
}

&webmin_log($text{'create_process_webminlog'}, undef, $in{'process_name'});
&ui_print_footer("", $text{'return_index'});
