#! /usr/bin/perl

require 'supervisor-lib.pl';
use RPC::XML;
use RPC::XML::Client;
use Scalar::Util qw(looks_like_number);
&ReadParse();


&redirect("") if(not $in{'process'} or not $in{'node'});

if($in{'type'} eq "stop")
{
	&stop_node_process($in{'process'},$in{'node'});
	&webmin_log($text{'do_node_process_stopwebminlog'}, undef, "$in{'node'} - $in{'process'}");
	
	&redirect($in{'redir'});
}
elsif($in{'type'} eq "start")
{
	&start_node_process($in{'process'},$in{'node'});
	&webmin_log($text{'do_node_process_startwebminlog'}, undef, "$in{'node'} - $in{'process'}");
	&redirect($in{'redir'});

}
elsif($in{'type'} eq "clear_log")
{
	&clearlogs_node_process($in{'process'},$in{'node'});
	&webmin_log($text{'do_node_process_clearlogwebminlog'}, undef, "$in{'node'} - $in{'process'}");
	&redirect($in{'redir'});
}
elsif($in{'type'} eq "restart")
{
	&restart_node_process($in{'process'},$in{'node'});
	&webmin_log($text{'do_node_process_restartwebminlog'}, undef, "$in{'node'} - $in{'process'}");

	&redirect($in{'redir'});
}
elsif($in{'type'} eq "readstdout")
{
	&ui_print_header(undef, $text{'do_node_process_readstdoutlog'},"");
	&error($text{'do_node_process_offseterr'}) if(not &looks_like_number($in{'offset'}) or $in{'offset'} lt "0");
	&error($text{'do_node_process_lengtherr'}) if(not &looks_like_number($in{'length'}) or $in{'length'} lt "0");

	my $log=&read_node_process_stdoutlog($in{'node'},$in{'process'},$in{'offset'},$in{'length'});
	$log=~s/\n/<br>/g;

	print &ui_table_start($text{'do_node_process_readstdoutlog'});
	print "$text{'do_node_process_node'} : $in{'node'}<br>";
	print "$text{'do_node_process_process'} : $in{'process'}<br>";
	print "$text{'do_node_process_offset'} : $in{'offset'}<br>";
       	print "$text{'do_node_process_length'} : $in{'length'}";
	print &ui_hr();
	print $log;
	print &ui_table_end();
	

	&webmin_log($text{'do_node_process_readstdoutlog_webminlog'}, undef, "$in{'node'} - $in{'process'} $text{'do_node_process_offset'}:$in{'offset'}, $text{'do_node_process_length'}:$in{'length'}");
	&ui_print_footer($in{'redir'}, $text{'return_back'});
}
elsif($in{'type'} eq "readstderr")
{
        &ui_print_header(undef, $text{'do_node_process_readstderrlog'},"");
        &error($text{'do_node_process_offseterr'}) if(not &looks_like_number($in{'offset'}) or $in{'offset'} lt "0");
        &error($text{'do_node_process_lengtherr'}) if(not &looks_like_number($in{'length'}) or $in{'length'} lt "0");

        my $log=&read_node_process_stderrlog($in{'node'},$in{'process'},$in{'offset'},$in{'length'});
        $log=~s/\n/<br>/g;

        print &ui_table_start($text{'do_node_process_readstderrlog'});
        print "$text{'do_node_process_node'} : $in{'node'}<br>";
        print "$text{'do_node_process_process'} : $in{'process'}<br>";
        print "$text{'do_node_process_offset'} : $in{'offset'}<br>";
        print "$text{'do_node_process_length'} : $in{'length'}";
        print &ui_hr();
        print $log;
        print &ui_table_end();


        &webmin_log($text{'do_node_process_readstderrlog_webminlog'}, undef, "$in{'node'} - $in{'process'} $text{'do_node_process_offset'}:$in{'offset'}, $text{'do_node_process_length'}:$in{'length'}");
	&ui_print_footer($in{'redir'}, $text{'return_back'});

}
elsif($in{'type'} eq "tailstdout")
{
        &ui_print_header(undef, $text{'do_node_process_tailstdoutlog'},"");
        &error($text{'do_node_process_offseterr'}) if(not &looks_like_number($in{'offset'}) or $in{'offset'} lt "0");
        &error($text{'do_node_process_lengtherr'}) if(not &looks_like_number($in{'length'}) or $in{'length'} lt "0");

        my @log=&tail_node_process_stdoutlog($in{'node'},$in{'process'},$in{'offset'},$in{'length'});
	my $output=$log[0][0];
	$output=~s/\n/<br>/g;

        print &ui_table_start($text{'do_node_process_tailstdoutlog'});
        print "$text{'do_node_process_node'} : $in{'node'}<br>";
        print "$text{'do_node_process_process'} : $in{'process'}<br>";
        print "$text{'do_node_process_offset'} : $in{'offset'} / $log[0][1]<br>";
        print "$text{'do_node_process_length'} : $in{'length'}";
        print &ui_hr();
        print $output;
        print &ui_table_end();
        

        &webmin_log($text{'do_node_process_tailstdoutlog_webminlog'}, undef, "$in{'node'} - $in{'process'} $text{'do_node_process_offset'}:$in{'offset'}, $text{'do_node_process_length'}:$in{'length'}");
	&ui_print_footer($in{'redir'}, $text{'return_back'});
}
elsif($in{'type'} eq "tailstderr")
{
        &ui_print_header(undef, $text{'do_node_process_tailstderrlog'},"");
        &error($text{'do_node_process_offseterr'}) if(not &looks_like_number($in{'offset'}) or $in{'offset'} lt "0");
        &error($text{'do_node_process_lengtherr'}) if(not &looks_like_number($in{'length'}) or $in{'length'} lt "0");

        my @log=&tail_node_process_stderrlog($in{'node'},$in{'process'},$in{'offset'},$in{'length'});
        my $output=$log[0][0];
        $output=~s/\n/<br>/g;

        print &ui_table_start($text{'do_node_process_tailstderrlog'});
        print "$text{'do_node_process_node'} : $in{'node'}<br>";
        print "$text{'do_node_process_process'} : $in{'process'}<br>";
        print "$text{'do_node_process_offset'} : $in{'offset'} / $log[0][1]<br>";
        print "$text{'do_node_process_length'} : $in{'length'}";
        print &ui_hr();
        print $output;
        print &ui_table_end();


        &webmin_log($text{'do_node_process_tailstderrlog_webminlog'}, undef, "$in{'node'} - $in{'process'} $text{'do_node_process_offset'}:$in{'offset'}, $text{'do_node_process_length'}:$in{'length'}");
	&ui_print_footer($in{'redir'}, $text{'return_back'});
}


