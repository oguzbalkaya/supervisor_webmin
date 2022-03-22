#! /usr/bin/perl

BEGIN { push(@INC, ".."); };
use WebminCore;
&init_config();


sub get_pid
{
	if(-e $config{'pid_file'})
	{
		return `cat $config{'pid_file'}`;
	}
	else
	{
		return 0;
	}
}

sub start_supervisor
{
	if($config{'start_cmd'}){
		my $out = `$config{'start_cmd'} 2>&1 </dev/null`;
		return "<pre>$out</pre>" if($?);
	}
	else
	{		
		my $out = `systemctl start supervisor 2>&1 </dev/null`;
		return "<pre>$out</pre>" if($?);
	}
	return undef;
}

sub stop_supervisor
{
        if($config{'stop_cmd'}){
                my $out = `$config{'stop_cmd'} 2>&1 </dev/null`;
                return "<pre>$out</pre>" if($?);
        }
        else
        {
		my $pid = &get_pid();
		$pid || return "err";
		&kill_logged('TERM',$pid);
        }
        return undef;
}

sub restart_supervisor
{
        if($config{'restart_cmd'}){
                my $out = `$config{'restart_cmd'} 2>&1 </dev/null`;
                return "<pre>$out</pre>" if($?);
        }
        else
        {
		my $pid = &get_pid();
		$pid || return "err";
		&kill_logged('HUP',$pid);
        }
        return undef;
}

sub get_version
{
	my $version = `$config{'supervisord_cmd'} -v 2>&1`;
	if ($? == 127)
	{
		return undef;
	}
	return $version;
}

sub buttons
{
	my @buttons;
	my $pid = &get_pid();
	if($pid!=0){
		#stop,restart
		push(@buttons, &ui_link("restart.cgi", $text{'index_restart'}));
		push(@buttons, &ui_link("stop.cgi", $text{'index_stop'}));
	}
	else
	{
		#start
		push(@buttons, &ui_link("start.cgi", $text{'index_start'}));
	}
	return join("<br>\n", @buttons);

}

sub get_subprocess_files
{
	if( $config{'subprocess_files_path'} eq "" )
	{
		&error(&text('get_subprocess_files_noneerr', "@{[&get_webprefix()]}/config.cgi?$module_name"));
	}
	else
	{
		if( not -e $config{'subprocess_files_path'} )
		{
			&error(&text('get_subprocess_files_notexist', "$config{'subprocess_files_path'}"));
		}
		else
		{
			opendir my $dir, $config{'subprocess_files_path'} or die &error(&text("get_subprocess_files_readerr",$config{'subprocess_files_path'}));
			my @files= readdir $dir;
			closedir $dir;
			my $index1=0;
			my $index2=0;
			$index1++ until $files[$index1] eq ".";
			splice(@files, $index1, 1);
			$index2++ until $files[$index2] eq "..";
			splice(@files, $index2, 1);
			for(my $i=0;$i<=$#files;$i++){
				$files[$i] = "$config{'subprocess_files_path'}$files[$i]";
			}
			return @files;	
		}
	}

}

sub get_subprocesses_infos
{
	my $info = `$config{'supervisorctl_cmd'}`;
	$info =~ s/supervisor>//g;
	my @processes = split(/\n/,$info);
	my @process_infos=();
	for my $process(@processes)
	{
		$process=~s/,//g;
		my @infos=split(' ',$process);
		my $data= {
			'name' => $infos[0],
			'status' => $infos[1],
			'pid' => $infos[3],
			'uptime' => $infos[5]
		};
		next if ($data->{'name'} eq "");
		push(@process_infos,$data);
	}
	return @process_infos;
}

sub list_processes
{
	my @processes=&get_subprocesses_infos();
	my $size=@processes;	
	print &ui_form_start("do.cgi","post");
	print &ui_form_end( [
		       	["refreshpage",$text{'index_restartpage'}],	
			["stopall",$text{'index_stopall'}],
		       	["restartall",$text{'list_processes_restartall'}],
			["reread",$text{'list_processes_reread'}],
			["create",$text{'list_processes_create'}],
			["createmanually",$text{'list_processes_createmanually'}],
			["creategroup",$text{'list_processes_creategroup'}]
		]);

	print &ui_table_start($text{'list_processes_tabletitle'}, "width=90%", 7);
	print &ui_columns_start([
			$text{'list_processes_name'},
			$text{'list_processes_status'},
			$text{'list_processes_pid'},
			$text{'list_processes_uptime'},
			$text{'list_processes_startstop'},
			$text{'list_processes_restart'},
			$text{'index_clear'},
			$text{'list_processes_tail'}
		]);
	if($size == 0)
	{
		print &ui_columns_row(
                                [ $text{'create_process_noprocess'}, "", "", "","","","","" ]);
	}
	else
	{
		for my $process(@processes)
		{
			my $status=$process->{'status'};
			my $pid;
			my $uptime;
			my $startstopbutton="<a href='do_process.cgi?type=start&process=".&urlize($process->{'name'})."'>".&ui_submit($text{'list_processes_start'})."</a>";
			my $restartbutton="<a href='do_process.cgi?type=restart&process=".&urlize($process->{'name'})."'>".&ui_submit($text{'list_processes_restart'})."</a>";
			my $clearlogbutton="<a href='do_process.cgi?type=clear_log&process=".&urlize($process->{'name'})."'>".&ui_submit($text{'index_clear'})."</a>";
			my $tailbutton="<a href='tail.cgi?process=".&urlize($process->{'name'})."'>".&ui_submit($text{'list_processes_tail'})."</a>";
			if($status eq "RUNNING")
			{
				$status="<h5 style='color:green;'>$process->{'status'}</h4>";
				$pid=$process->{'pid'};
				$uptime=$process->{'uptime'};
				$startstopbutton="<a href='do_process.cgi?type=stop&process=".&urlize($process->{'name'})."'>".&ui_submit($text{'index_stop'})."</a>";
			}
			elsif($status eq "STOPPED")
			{
				$status="<h5 style='color:red;'>$process->{'status'}</h4>";
                        	$pid="-";
                        	$uptime="-";
			}
			else
			{
				$status=$status;
                        	$pid=$process->{'pid'};
                        	$uptime=$process->{'uptime'};
			}
			print &ui_columns_row(
				[ $process->{'name'}, $status, $pid, $uptime,$startstopbutton,$restartbutton,$clearlogbutton,$tailbutton ]);
		}
	}
	
	print &ui_columns_end();
	print &ui_table_end();

}

sub stop_process
{
	my $process = shift;
	my $c=`$config{'supervisorctl_cmd'} stop $process 2>&1`;
	&error($c) if($?);
}

sub start_process
{
	my $process = shift;
	my $c=`$config{'supervisorctl_cmd'} start $process 2>&1`;
	&error($c) if($?);
}

sub clear_process_log
{
	my $process = shift;
	my $c=`$config{'supervisorctl_cmd'} clear $process 2>&1`;
	&error($c) if($?);
}

sub restart_process
{
        my $process = shift;
        my $c=`$config{'supervisorctl_cmd'} restart $process 2>&1`;
        &error($c) if($?);
}

sub restart_all
{
	my $c = `$config{'supervisorctl_cmd'} restart all 2>&1`;
        &error($c) if($?);
}

sub stop_all
{
	my $c = `$config{'supervisorctl_cmd'} stop all 2>&1`;
        &error($c) if($?);
}

sub start_group
{
	my $group_name=shift;
	my $c = `$config{'supervisorctl_cmd'} start $group_name:* 2>&1`;
	&error($c) if($?);
}

sub stop_group
{
	my $group_name=shift;
	my $c = `$config{'supervisorctl_cmd'} stop $group_name:* 2>&1`;
	&error($c) if($?);
}

sub get_tail_process
{
	my $process = shift;
	my $c=`$config{'supervisorctl_cmd'} tail $process 2>&1`;
	&error($c) if($?);
	return $c;
}

sub reread
{
	my $c=`$config{'supervisorctl_cmd'} reread 2>&1`;
	&error($c) if($?);
}


sub create_process
{
	my %inp=%{$_[0]};
	my $file="";
	if($config{'subprocess_files_path'} eq "")
	{
		$file="$config{'supervisor_conf'}";
		my $c=`echo "\n" >> $file`;
	}
	else
	{	
		$file="$config{'subprocess_files_path'}/$inp{'process_name'}.conf";
		&error(&text('create_process_fileexisterr',$file)) if(-e $file);
	}
	my $c=`echo "[program:$inp{'process_name'}]" >> $file 2>&1`;
	for(keys %inp)
	{
		next if(!defined($inp{$_}) or $inp{$_} eq "");
		next if($_ eq "process_name");
		$c=`echo "$_=$inp{$_}" >> $file 2>&1`;
		&error($c) if($?);
	}

	&restart_supervisor() if($config{'autorestart'} eq "1");
}

sub create_process_manually
{
	my($filename,$content)=@_;
	my $filepath="";
	print("$filename");
	if($filename eq "")
	{	
		$filepath=$config{'supervisor_conf'};
		my $c=`echo "\n" >> $filepath 2>&1`;
		&error($c) if($?);
	}
	else
	{
		$filepath="$config{'subprocess_files_path'}/$filename.conf";
		&error(&text('create_process_fileexisterr',$filename)) if(-e $filepath);
	}
	my $c=`echo "$content" >> $filepath 2>&1`;
	&error($c) if($?);
	&restart_supervisor() if($config{'autorestart'} eq "1");
}


sub is_process_exist
{
	my $process_name=shift;
	my @processes=&get_subprocesses_infos();
	for my $process(@processes)
	{
		my @data = split(":",$process->{'name'});
		my $size=@data;
		if($size > 1)
		{
			if($data[1] eq $process_name)
			{
				return 1;
			}
		}
		else
		{
			if($process->{'name'} eq $process_name)
			{
				return 1;
			}
		}
	
	}
	return 0;
}


sub save_group
{
	my %inp=%{$_[0]};
	my $file="";
	my @processes=split(",",$inp{'programs'});

	for my $process(@processes)
        {
                &error(&text('create_group_processnotexisterr',$process)) if(not &is_process_exist($process));
        }

	if($config{'subprocess_files_path'} eq "")
	{
	$file=$config{'supervisor_conf'};
	my $c=`echo "\n" >> $file 2>&1`;
	&error($c) if($?);
	}
	else
	{
	$file="$config{'subprocess_files_path'}/group_$inp{'group_name'}.conf";
	&error(&text('create_group_fileexisterr',$file)) if(-e $file);
	}

	my $c=`echo "[group:$inp{'group_name'}]" >> $file 2>&1`;
        &error($c) if($?);
        $c=`echo "programs=$inp{'programs'}" >> $file 2>&1`;
        &error($c) if($?);
	if($inp{'priority'} ne "")
	{
		$c=`echo "priority=$inp{'priority'}" >> $file 2>&1`;
                &error($c) if($?);
	}

	&restart_supervisor() if($config{'autorestart'});
}

sub group_operations
{

	print &ui_form_start('group_operations.cgi','post');
	print &ui_columns_start([]);
	print &ui_columns_row(["$text{'group_operations_groupname'}    ".&ui_textbox("groupname","").""]);
	print &ui_columns_end();
	print &ui_submit($text{'index_startall'},"type")."".&ui_submit($text{'index_stopall'},"type");;
	print &ui_form_end();

}



