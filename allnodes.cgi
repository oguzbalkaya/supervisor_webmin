#! /usr/bin/perl
require './supervisor-lib.pl';
&ReadParse();
&ui_print_header(undef, $text{'nodes_title'},"");
use RPC::XML;
use RPC::XML::Client;

my @nodes=&get_nodes();

for my $node(@nodes)
{
	next if(!&check_node_connection($node->{'rpc2address'}));
	print &ui_hidden_start("$node->{'name'} ($node->{'rpc2address'})","$node->{'name'}",1,undef);
	&list_node_processes($node->{'rpc2address'},$node->{'name'},"allnodes.cgi");	
	print &ui_hidden_end("$node->{'name'}");
	print &ui_hr();
}

&ui_print_footer('nodes.cgi', $text{'return_nodes'});

