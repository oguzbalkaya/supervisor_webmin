#! /usr/bin/perl
require './supervisor-lib.pl';
use RPC::XML;
use RPC::XML::Client;
&ReadParse();
&ui_print_header(undef, &text('node_details_title',"$in{'node'}"),"");

my $node_info=&get_node_info($in{'node'});

&error($text{'node_notexisterr'}) if(!defined($node_info));


if(!&check_node_connection($node_info->{'rpc2address'}))
{
	&error(&text('node_details_connectionerr',$node_info->{'rpc2address'}));
}
else
{

	my $state=&get_node_state($node_info->{'rpc2address'});
	print &ui_table_start($text{'node_details_generalinfo'}, undef, 2);

	print &ui_table_row($text{'node_details_name'},$node_info->{'name'});
	print &ui_table_row($text{'node_details_rpc2address'},$node_info->{'rpc2address'});
	print &ui_table_row($text{'node_details_apiversion'},&get_node_api_version($node_info->{'rpc2address'}));
	print &ui_table_row($text{'node_details_supervisorversion'},&get_node_supervisor_version($node_info->{'rpc2address'}));
	print &ui_table_row($text{'node_details_state'},"$state->{'statename'} ($text{'node_details_statecode'} : $state->{'statecode'})");
	print &ui_table_row($text{'node_details_pid'},&get_node_pid($node_info->{'rpc2address'}));




	print &ui_table_end();


	print &ui_hr();

	&list_node_processes($node_info->{'rpc2address'},$node_info->{'name'},"node_details.cgi?node=$node_info->{'name'}");

}

&ui_print_footer('nodes.cgi', $text{'return_nodes'},'',$text{'return_index'});
