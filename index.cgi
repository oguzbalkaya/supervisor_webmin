#!/usr/bin/perl
require 'supervisor-lib.pl';

my $pid = &get_pid();
my $version = &get_version();


if( !defined($version) ){

	&ui_print_header(undef, $text{'index_title'}, "", undef, 1, 1, 0, 
		&help_search_link("supervisor", "man", "doc", "google"));

	print "<p>",&text('index_notinstalled', "@{[&get_webprefix()]}/config.cgi?$module_name"),"<p>\n";
	&foreign_require("software", "software-lib.pl");
	$lnk = &software::missing_install_link("supervisor", $module_name, 
		"../$module_name/", $module_name);
	print $lnk,"<p>\n" if ($lnk);
}
else
{
	###
	&ui_print_header(undef, $text{'index_title'}, "", undef, 1, 1, undef,
	&buttons()."<br>".
	&help_search_link("supervisord", "man", "doc", "google"), undef, undef,
	&text('index_version', $version));
	###

	#Edit manual
	push(@links, "edit_manual.cgi");
	push(@titles, $text{'edit_manual_title'});
	push(@icons, "images/edit_manual.png");

	push(@links, "edit_subprocess_conf.cgi");
        push(@titles, $text{'edit_manual_subprocess_files'});
        push(@icons, "images/edit_manual.png");


	&icons_table(\@links, \@titles, \@icons, 4);

	print &ui_hr();
	



	if($pid)
	{
		&list_processes();
		print &ui_hr();
		&group_operations();
	
	}
	else
	{
		print $text{'index_notrunning'};
	}

}
&ui_print_footer('/', $text{'index'});
