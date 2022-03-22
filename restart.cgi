#! /usr/bin/perl
#restart.cgi
#Restart the supervisor daemon

require './supervisor-lib.pl';
&ReadParse();
&error_setup($text{'restart_supervisor_error'});
my $err = &restart_supervisor();
&error($err) if($err);
&webmin_log($text{'restart_supervisor_webminlog'});
sleep(2);
&redirect("");

