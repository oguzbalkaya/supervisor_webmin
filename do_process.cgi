#! /usr/bin/perl

require 'supervisor-lib.pl';
&ReadParse();

&redirect("") if(not $in{'process'} or not $in{'type'});

if($in{'type'} eq "stop")
{
	&stop_process($in{'process'});	
	&webmin_log($text{'do_process_stop_webminlog'}, undef, $in{'process'});
}
elsif($in{'type'} eq "start")
{
	&start_process($in{'process'});
	&webmin_log($text{'do_process_start_webminlog'}, undef, $in{'process'});
}
elsif($in{'type'} eq "clear_log")
{
	&clear_process_log($in{'process'});
	&webmin_log($text{'do_process_clear_webminlog'}, undef, $in{'process'});
}
elsif($in{'type'} eq "restart")
{
	&restart_process($in{'process'});
	&webmin_log($text{'do_process_restart_webminlog'}, undef, $in{'process'});

}

&redirect("");
