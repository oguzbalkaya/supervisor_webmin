#! /usr/bin/perl
#start.cgi
#Start the supervisor daemon


require './supervisor-lib.pl';
&ReadParse();
&error_setup($text{'start_supervisor_error'});
my $err = &start_supervisor();
&error($err) if($err);
sleep(1);
&webmin_log($text{'start_supervisor_webminlog'});
&redirect("");
