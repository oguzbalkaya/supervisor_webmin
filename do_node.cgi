#! /usr/bin/perl
#Refresh or stop all subprocesses
require './supervisor-lib.pl';
use RPC::XML;
use RPC::XML::Client;
&ReadParse();

&redirect("") if(not $in{'node'});

if($in{'restartall'})
{
	&restartall_node_processes($in{'node'});
	&webmin_log($text{'do_restart_all_webminlog'});
}
elsif($in{'stopall'})
{
	&stopall_node_processes($in{'node'});
	&webmin_log($text{'do_stop_all_webminlog'});
}
elsif($in{'reread'})
{
	&reload_node_config($in{'node'});
}
elsif($in{'refreshpage'})
{
	&redirect($in{'redir'});
}
&redirect($in{'redir'});
