#! /usr/bin/perl
require './supervisor-lib.pl';
&ReadParse();
&ui_print_header(undef, $text{'create_process_title'},"");

my $file="";
if( $config{'subprocess_files_path'} eq "" )
{
	$file=$config{'supervisor_conf'};
}
else
{
	$file=$config{'subprocess_files_path'};
}

print &ui_form_start('save_process.cgi');

print "$text{'create_process_required'}<br>";
print "$text{'create_process_manually'}<br>";
print "$text{'create_process_emptyinfo'}<br>";
print &text("create_process_fileinfo","$file","@{[&get_webprefix()]}/config.cgi?$module_name");
print &ui_hr();
print &ui_columns_start([
		$text{'create_process_key'},
		$text{'create_process_value'},
	]);
print &ui_columns_row([ "$text{'create_process_process_name'}<i style='color:red;'>*</i>" , &ui_textbox("process_name","") ]);
print &ui_columns_row([ "$text{'create_process_command'}<i style='color:red;'>*</i> " , &ui_textbox("command","") ]);
print &ui_columns_row([ $text{'create_process_numprocs'} , &ui_textbox("numprocs","") ]);
print &ui_columns_row([ $text{'create_process_events'} , &ui_textbox("events","") ]);
print &ui_columns_row([ $text{'create_process_buffer_size'} , &ui_textbox("buffer_size","") ]);
print &ui_columns_row([ $text{'create_process_directory'} , &ui_textbox("directory","") ]);
print &ui_columns_row([ $text{'create_process_umask'} , &ui_textbox("umask","") ]);
print &ui_columns_row([ $text{'create_process_priority'} , &ui_textbox("priority","") ]);
print &ui_columns_row([ $text{'create_process_autostart'} , &ui_textbox("autostart","") ]);
print &ui_columns_row([ $text{'create_process_autorestart'} , &ui_textbox("autorestart","") ]);
print &ui_columns_row([ $text{'create_process_startsecs'} , &ui_textbox("startsecs","") ]);
print &ui_columns_row([ $text{'create_process_startretries'} , &ui_textbox("startretries","") ]);
print &ui_columns_row([ $text{'create_process_exitcodes'} , &ui_textbox("exitcodes","") ]);
print &ui_columns_row([ $text{'create_process_stopsignal'} , &ui_textbox("stopsignal","") ]);
print &ui_columns_row([ $text{'create_process_stopwaitsecs'} , &ui_textbox("stopwaitsecs","") ]);
print &ui_columns_row([ $text{'create_process_stopasgroup'} , &ui_textbox("stopasgroup","") ]);
print &ui_columns_row([ $text{'create_process_killasgroup'} , &ui_textbox("killasgroup","") ]);
print &ui_columns_row([ $text{'create_process_user'} , &ui_textbox("user","") ]);
print &ui_columns_row([ $text{'create_process_redirect_stderr'} , &ui_textbox("redirect_stderr","") ]);
print &ui_columns_row([ $text{'create_process_stdout_logfile'} , &ui_textbox("stdout_logfile","") ]);
print &ui_columns_row([ $text{'create_process_stdout_logfile_maxbytes'} , &ui_textbox("stdout_logfile_maxbytes","") ]);
print &ui_columns_row([ $text{'create_process_stdout_logfile_backups'} , &ui_textbox("stdout_logfile_backups","") ]);
print &ui_columns_row([ $text{'create_process_stdout_events_enabled'} , &ui_textbox("stdout_events_enabled","") ]);
print &ui_columns_row([ $text{'create_process_stderr_logfile'} , &ui_textbox("stderr_logfile","") ]);
print &ui_columns_row([ $text{'create_process_stderr_logfile_maxbytes'} , &ui_textbox("stderr_logfile_maxbytes","") ]);
print &ui_columns_row([ $text{'create_process_stderr_logfile_backups'} , &ui_textbox("stderr_logfile_backups","") ]);
print &ui_columns_row([ $text{'create_process_stderr_events_enabled'} , &ui_textbox("stderr_events_enabled","") ]);
print &ui_columns_row([ $text{'create_process_environment'} , &ui_textbox("environment","") ]);
print &ui_columns_row([ $text{'create_process_serverurl'} , &ui_textbox("serverurl","") ]);

print &ui_columns_end();

print &ui_submit($text{'create_process_save'});
print &ui_form_end();

&ui_print_footer("", $text{'return_index'});
