#! /usr/bin/perl
require './supervisor-lib.pl';
&ReadParse();
use RPC::XML;
use RPC::XML::Client;
&error($text{'group_operations_namerequirederr'}) if($in{'groupname'} eq "");
&redirect($in{'redir'}) if($in{'node_name'} eq "");

if($in{'type'} eq $text{'index_startall'})
{

	&start_node_group($in{'node_name'},$in{'groupname'});
	&webmin_log($text{'group_operations_startwebminlog'}, undef, "$in{'node_name'} - $in{'groupname'}");
}
elsif($in{'type'} eq $text{'index_stopall'})
{
	&stop_node_group($in{'node_name'},$in{'groupname'});
	&webmin_log($text{'group_operations_stopwebminlog'}, undef, "$in{'node_name'} - $in{'groupname'}");
}


&redirect($in{'redir'});
