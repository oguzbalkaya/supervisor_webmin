#! /usr/bin/perl

require './supervisor-lib.pl';
&ReadParse();
&error($text{'delete_node_namerequired'}) if(not $in{'node'} or $in{'node'} eq "");

my $node_info=&get_node_info($in{'node'});
&error($text{'delete_node_notfound'}) if(!defined($node_info));


&delete_node($node_info);


&webmin_log($text{'delete_node_webminlog'}, undef, $in{'node_name'});
&redirect("nodes.cgi");
