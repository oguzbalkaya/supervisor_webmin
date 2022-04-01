#! /usr/bin/perl

require './supervisor-lib.pl';
&ReadParse();
&error($text{'create_node_namerequired'}) if(not $in{'node_name'} or $in{'node_name'} eq "");
&error($text{'create_node_rpc2addressrequired'}) if(not $in{'rpc2_address'} or $in{'rpc2_address'} eq "");

&save_node($in{'node_name'},$in{'rpc2_address'});


&webmin_log($text{'create_node_webminlog'}, undef, $in{'node_name'});
&redirect("nodes.cgi");
