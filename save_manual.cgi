#! /usr/bin/perl

require './supervisor-lib.pl';
&error_setup($text{'edit_manual_error'});
&ReadParseMime();


my @files = ( $config{'supervisor_conf'} );
$in{'file'} ||= $files[0];
&indexof($in{'file'}, @files) >= 0 || &error($text{'edit_manual_errorfile'});



&open_lock_tempfile(DATA,">$in{'file'}");
&print_tempfile(DATA, $in{'data'});
&close_tempfile(DATA);

&webmin_log($text{'edit_manual_webminlog'}, undef, $in{'file'});
&redirect("");
