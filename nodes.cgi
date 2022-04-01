#! /usr/bin/perl
require './supervisor-lib.pl';
&ReadParse();
&ui_print_header(undef, $text{'nodes_title'},"");
eval 'use RPC::XML';
eval 'use RPC::XML::Client';

if($@)
{
	print $text{'node_perlmodule_err'};
	&ui_print_footer('', $text{'return_index'});
	exit;
}
my @nodes=&get_nodes();
my $size=@nodes;
print &text("create_node_fileinfo",$config{'nodelist_path'},"@{[&get_webprefix()]}/config.cgi?$module_name");


print &ui_hr();

print &ui_form_start('save_node.cgi');
print &ui_table_start($text{'create_node_title'}, undef, 2);

print &ui_table_row($text{'create_node_name'},
        &ui_textbox('node_name', "", 40));

print &ui_table_row($text{'create_node_rpc2address'},
        &ui_textbox('rpc2_address', "", 40));

print &ui_table_end();
print &ui_form_end([ [ undef, $text{'create_node_create'} ] ]);


print &ui_columns_end();

print &ui_hr();


print "<a href=allnodes.cgi>".&ui_submit($text{'all_nodes_one_page'})."</a>";

print &ui_table_start($text{'nodes_list'}, undef, 3);


print &ui_columns_start([ 
		$text{'node_name'},
		$text{'node_rpc2address'},
		$text{'node_status'},
		$text{'node_delete'}
	]);


if($size == 0)
{
	print &ui_columns_row( ["",$text{'nodes_list_nonode'},""] );
}
else
{
	for my $node(@nodes)
	{
		my $status="<i style='color:green; font-weight:bold;'>CONNECTED</i>";
		if(!&check_node_connection($node->{'rpc2address'}))
		{
			$status="<i style='color:red;' font-weight:bold;>NOT CONNNECTED</i>";
		}

		print &ui_columns_row( [
				"<a href='node_details.cgi?node=".&urlize($node->{'name'})."'>$node->{'name'}</a>",
				$node->{'rpc2address'},
				$status,
				"<a href='delete_node.cgi?node=".&urlize($node->{'name'})."'>".&ui_submit($text{'node_delete'})."</a>"
		]);

	}
}

print &ui_columns_end();



print &ui_table_end();



&ui_print_footer('', $text{'return_index'});
