#! /usr/bin/perl
#stop.cgi
#Stop the supervisor daemon

require './supervisor-lib.pl';
&ReadParse();
&error_setup($text{'stop_supervisor_error'});
my $err = &stop_supervisor();
&error($err) if($err);
&webmin_log($text{'stop_supervisor_webminlog'});
&redirect("");

