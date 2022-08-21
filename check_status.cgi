#! /usr/bin/perl
#Check nodes status

require './supervisor-lib.pl';
&ReadParse();

eval 'use RPC::XML';
eval 'use RPC::XML::Client';

if($@)
{
        print $text{'node_perlmodule_err'};
        &ui_print_footer('', $text{'return_index'});
        exit;
}


&error_setup($text{'check_node_status_error'});
&check_node_status();
&webmin_log($text{'check_node_status_webminlog'});
&redirect("nodes.cgi");
