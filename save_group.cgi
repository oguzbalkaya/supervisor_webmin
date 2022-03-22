#! /usr/bin/perl

require './supervisor-lib.pl';
&ReadParse();
&ui_print_header(undef, $text{'create_process_title'},"");
&error($text{'create_group_namerequired'}) if(not $in{'group_name'} or $in{'group_name'} eq "");
&error($text{'create_group_programsrequired'}) if(not $in{'programs'} or $in{'programs'} eq "");

&save_group(\%in);


print "<i style='color:green;'>$text{'create_group_successinfo'}</i>";

if($config{'autorestart'} eq "1")
{
	print "<br>$text{'create_group_restartinfo'}";
}
else
{
	print "<br>$text{'create_group_norestartinfo'}";
}

&webmin_log($text{'create_group_webminlog'}, undef, $in{'group_name'});
&ui_print_footer("", $text{'return_index'});
