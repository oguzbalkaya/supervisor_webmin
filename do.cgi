#! /usr/bin/perl
#Refresh or stop all subprocesses
require './supervisor-lib.pl';
&ReadParse();

if($in{'restartall'})
{
	&restart_all();
	&webmin_log($text{'do_restart_all_webminlog'});
}
elsif($in{'stopall'})
{
	&stop_all();
	&webmin_log($text{'do_stop_all_webminlog'});
}
elsif($in{'create'})
{
	&redirect("create_process.cgi");
}
elsif($in{'createmanually'})
{
	&redirect("create_process_manually.cgi");
}
elsif($in{'refreshpage'})
{
	&redirect("");
}
elsif($in{'reread'})
{
	&reread();
}
elsif($in{'creategroup'})
{
	&redirect("create_group.cgi");
}
&redirect("");
