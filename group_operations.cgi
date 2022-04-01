#! /usr/bin/perl
require './supervisor-lib.pl';
&ReadParse();


&error($text{'group_operations_namerequirederr'}) if($in{'groupname'} eq "");

if($in{'type'} eq $text{'index_startall'})
{
	&start_group($in{'groupname'});
	&webmin_log($text{'group_operations_startwebminlog'}, undef, $in{'groupname'});
}
elsif($in{'type'} eq $text{'index_stopall'})
{
	&stop_group($in{'groupname'});
	&webmin_log($text{'group_operations_stopwebminlog'}, undef, $in{'groupname'});
}
&redirect("");

