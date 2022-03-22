#! /usr/bin/perl

require './supervisor-lib.pl';
&ReadParse();
&redirect("") if( not $in{'process'} );

&ui_print_header(undef, $text{'tail_title'},"");

my $tail=&get_tail_process($in{'process'});


print &ui_table_start(&text('tail_table_title',$in{'process'}),'width=100%',1);

$tail =~ s/\n/<br>/g;
print $tail;

print &ui_table_end();


&ui_print_footer("", $text{'return_index'});
