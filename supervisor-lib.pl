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
	my ($type,$node_name,$redir)=@_;
	my $post="";
	my $hid;
	if($type eq "index")
	{
		$post="group_operations.cgi";
	}
	elsif($type eq "node")
	{
		$post="node_group_operations.cgi";
		$hid=&ui_hidden("node_name","$node_name");
	}
	print &ui_form_start($post,'post');
	print &ui_columns_start([]);
	print &ui_columns_row(["$text{'group_operations_groupname'}    ".&ui_textbox("groupname","").""]);
	print $hid;
	print &ui_hidden("redir",$redir);
	print &ui_columns_end();
	print &ui_submit($text{'index_startall'},"type")."".&ui_submit($text{'index_stopall'},"type");;
	print &ui_form_end();

}


sub get_nodes
{
	my @nodes;
	my $line;
	open(CONF, $config{'nodelist_path'});
	while(<CONF>)
	{
		s/\r|\n//g;
		s/#.*$//;
		my ($name,$rpc2address) = split(/\s+/,$_);		
		if($name ne "" && $rpc2address ne "")
		{
			push(@nodes, { 
					'name' => $name,
					'rpc2address' => $rpc2address,
					'line' => $line
				});
		}
		$line++;
	}
	close(CONF);
	return @nodes;
}

sub get_node_info
{
	my $node_name=shift;
	my @nodes=&get_nodes();
	for my $node(@nodes)
	{
		if($node->{'name'} eq $node_name)
		{
			return $node;
		}
	}
	return undef;
}


sub save_node
{
	my($node_name,$rpc2address)=@_;
	&error($text{'create_node_nodeexisterr'}) if(defined(&get_node_info($node_name)));
	open_tempfile(CONF,">>$config{'nodelist_path'}");
	print_tempfile(CONF, $node_name."  ".$rpc2address."\n");
	close_tempfile(CONF);
}

sub delete_node
{
	my $node=shift;
	my $lref = &read_file_lines($config{'nodelist_path'});
	splice(@$lref, $node->{'line'}, 1);
	&flush_file_lines($config{'nodelist_path'});
}



sub connect_to_rpc2
{
	my $rpc2address=shift;
	my $xmlrpc=RPC::XML::Client->new($rpc2address);
	return $xmlrpc;
}

sub get_node_api_version
{
	my $rpc2address=shift;
	my $xmlrpc=&connect_to_rpc2($rpc2address);
	my $apiversion=$xmlrpc->send_request( 'supervisor.getAPIVersion' );
	return $apiversion->value;
}

sub get_node_supervisor_version
{
        my $rpc2address=shift;
        my $xmlrpc=&connect_to_rpc2($rpc2address);
        my $supervisorversion=$xmlrpc->send_request( 'supervisor.getSupervisorVersion' );
        return $supervisorversion->value;
}

sub get_node_state
{
	my $rpc2address=shift;
	my $xmlrpc=&connect_to_rpc2($rpc2address);
	my $state=$xmlrpc->send_request( 'supervisor.getState' );
	return $state->value;
}

sub get_node_pid
{
	my $rpc2address=shift;
        my $xmlrpc=&connect_to_rpc2($rpc2address);
        my $pid = $xmlrpc->send_request( 'supervisor.getPID' );
        return $pid->value;
}

sub get_node_processes
{
	my $rpc2address=shift;
	my $xmlrpc=&connect_to_rpc2($rpc2address);
	my $processes=$xmlrpc->send_request( 'supervisor.getAllProcessInfo' );
	my @process_list=@{$processes->value};
	return @process_list;
}



sub list_node_processes
{
	my ($rpc2address,$node_name,$redir)=@_;

	my @processes=&get_node_processes($rpc2address);

	my $size=@processes;
	

	print &ui_form_start("do_node.cgi","post");
        print &ui_hidden("node",$node_name);
	print &ui_hidden("redir",$redir);
	print &ui_form_end( [
                        ["refreshpage",$text{'index_restartpage'}],
                        ["stopall",$text{'index_stopall'}],
                        ["restartall",$text{'list_processes_restartall'}],
                        ["reread",$text{'list_processes_reread'}],
                ]);

	print &ui_table_start($text{'list_processes_tabletitle'}, "width=90%", 7);
        print &ui_columns_start([
                	$text{'node_details_processname'},
			$text{'node_details_group'},
			$text{'node_details_description'},
			$text{'node_details_state'},
			$text{'node_details_startstop'},
			$text{'node_details_restart'},
			$text{'node_details_clearlog'},
			$text{'node_details_more'}
		]);

        if($size == 0)
        {
                print &ui_columns_row(
                                [ $text{'create_process_noprocess'}, "", "", "","","","","","" ]);
        }
        else
        {
		for my $process(@processes)
		{
			my $process_name="$process->{'group'}:$process->{'name'}";
			my $status=$process->{'statename'};
			my $startstopbutton="<a href='do_node_process.cgi?redir=$redir&type=start&node=$node_name&process=".&urlize($process_name)."'>".&ui_submit($text{'list_processes_start'})."</a>";
                        my $restartbutton="<a href='do_node_process.cgi?redir=$redir&type=restart&node=$node_name&process=".&urlize($process_name)."'>".&ui_submit($text{'list_processes_restart'})."</a>";
                        my $clearlogbutton="<a href='do_node_process.cgi?redir=$redir&type=clear_log&node=$node_name&process=".&urlize($process->{'name'})."'>".&ui_submit($text{'index_clear'})."</a>";

			if($status eq "RUNNING")
			{
				$status="<h5 style='color:green;'>$process->{'statename'}</h4>";
				$startstopbutton="<a href='do_node_process.cgi?redir=$redir&type=stop&node=$node_name&process=$process_name'>".&ui_submit($text{'index_stop'})."</a>";
			}
			elsif($status eq "STOPPED")
			{
				$status="<h5 style='color:red;'>$process->{'statename'}</h4>";
			}
			print &ui_columns_row(
                                [ $process->{'name'}, $process->{'group'}, $process->{'description'}, $status,$startstopbutton,$restartbutton,$clearlogbutton, &ui_select_node_op($node_name,"$process->{'group'}:$process->{'name'}",$redir) ]);

				
		}
	}

	print &ui_columns_end();
	print &ui_table_end();
	
	&group_operations("node",$node_name,$redir);

}

sub stop_node_process
{
	my($process_name,$node_name)=@_;
	my $node=&get_node_info($node_name);
	my $xmlrpc=&connect_to_rpc2($node->{'rpc2address'});
	my $c=$xmlrpc->send_request( 'supervisor.stopProcess',$process_name );
}

sub start_node_process
{
        my($process_name,$node_name)=@_;
        my $node=&get_node_info($node_name);
        my $xmlrpc=&connect_to_rpc2($node->{'rpc2address'});
        my $c=$xmlrpc->send_request( 'supervisor.startProcess', $process_name);
}

sub restart_node_process
{
        my($process_name,$node_name)=@_;
        my $node=&get_node_info($node_name);
	&stop_node_process($process_name,$node_name);
	&start_node_process($process_name,$node_name);	
}

sub clearlogs_node_process
{
        my($process_name,$node_name)=@_;
        my $node=&get_node_info($node_name);
        my $xmlrpc=&connect_to_rpc2($node->{'rpc2address'});
        my $c=$xmlrpc->send_request( 'supervisor.clearProcessLogs',$process_name);
}

sub stopall_node_processes
{
	my $node_name=shift;
	my $node=&get_node_info($node_name);
	my $xmlrpc=&connect_to_rpc2($node->{'rpc2address'});
	my $c=$xmlrpc->send_request( 'supervisor.stopAllProcesses' );
}


sub startall_node_processes
{
        my $node_name=shift;
        my $node=&get_node_info($node_name);
        my $xmlrpc=&connect_to_rpc2($node->{'rpc2address'});
        my $c=$xmlrpc->send_request( 'supervisor.startAllProcesses' );
}

sub restartall_node_processes
{
        my $node_name=shift;
        my $node=&get_node_info($node_name);
	&stopall_node_processes($node_name);
	&startall_node_processes($node_name);
}

sub reload_node_config
{
	my $node_name=shift;
	my $node=&get_node_info($node_name);
	my $xmlrpc=&connect_to_rpc2($node->{'rpc2address'});
	my $c=$xmlrpc->send_request( 'supervisor.reloadConfig' );
}

sub start_node_group
{
	my ($node_name,$group_name)=@_;
	my $node=&get_node_info($node_name);
	my $xmlrpc=&connect_to_rpc2($node->{'rpc2address'});
	my $c=$xmlrpc->send_request( 'supervisor.startProcessGroup', $group_name);
}

sub stop_node_group
{
	my ($node_name,$group_name)=@_;
        my $node=&get_node_info($node_name);
        my $xmlrpc=&connect_to_rpc2($node->{'rpc2address'});
        my $c=$xmlrpc->send_request( 'supervisor.stopProcessGroup', $group_name);
}



sub ui_select_node_op
{
        my ($node_name,$process_name,$redir)=@_;
	my @options=(
		["readstdout",$text{'node_details_readstdout'}],
		["readstderr",$text{'node_details_readstderr'}],
		["tailstdout",$text{'node_details_tailstdout'}],
		["tailstderr",$text{'node_details_tailstderr'}]	
	);

        return "".&ui_form_start('do_node_process.cgi')."
        ".&ui_textbox("offset","",10,undef,undef,"placeholder=$text{'node_details_offset'}")."
	".&ui_textbox("length","",10,undef,undef,"placeholder=$text{'node_details_length'}")."
	".&ui_select("type","",\@options)."
	".&ui_hidden("node",$node_name)."
	".&ui_hidden("process",$process_name)."
	".&ui_hidden("redir",$redir)."
	".&ui_submit($text{'node_details_go'},"go")."
        ".&ui_form_end()."";
}



sub read_node_process_stdoutlog
{
	my($node_name,$process_name,$offset,$length)=@_;
	my $node=&get_node_info($node_name);
	my $xmlrpc=&connect_to_rpc2($node->{'rpc2address'});
	my $c=$xmlrpc->send_request( 'supervisor.readProcessStdoutLog' , $process_name,$offset,$length);
	return $c->value;
}

sub read_node_process_stderrlog
{
        my($node_name,$process_name,$offset,$length)=@_;
        my $node=&get_node_info($node_name);
        my $xmlrpc=&connect_to_rpc2($node->{'rpc2address'});
        my $c=$xmlrpc->send_request( 'supervisor.readProcessStderrLog' , $process_name,$offset,$length);
        return $c->value;
}


sub tail_node_process_stdoutlog
{
        my($node_name,$process_name,$offset,$length)=@_;
        my $node=&get_node_info($node_name);
        my $xmlrpc=&connect_to_rpc2($node->{'rpc2address'});
        my $c=$xmlrpc->send_request( 'supervisor.tailProcessStdoutLog' , $process_name,$offset,$length);
        return $c->value;
}

sub tail_node_process_stderrlog
{
        my($node_name,$process_name,$offset,$length)=@_;
        my $node=&get_node_info($node_name);
        my $xmlrpc=&connect_to_rpc2($node->{'rpc2address'});
        my $c=$xmlrpc->send_request( 'supervisor.tailProcessStderrLog' , $process_name,$offset,$length);
        return $c->value;
}


sub check_node_connection
{
	my $rpc2address=shift;
	my $xmlrpc=&connect_to_rpc2($rpc2address);
        my $state=$xmlrpc->send_request( 'supervisor.getState' );
	if(ref $state)
	{
		return 1;
	}
	else
	{
		return 0;
	}
}

