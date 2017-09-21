package MyScenario;
use strict;
use warnings;
use HTML::Entities;

sub load_scenario {

    my $scenario = {
	init_state => sub {
	    my $client_id = shift;
	    my $client_data = shift;
	    my $client_command = shift;
	    return('state_01','wait',"何か質問して下さい\n",$client_data);
	},
	state_01 => sub {
	    my $client_id = shift;
	    my $client_data = shift;
	    my $client_command = shift;
	    my $client_command_res = encode_entities($client_command,q{&<>"'});
	    my $response = "「 $client_command_res 」ですね。少々お待ち下さい。\n";
	    my $next_state = 'final_state';
	    my $mode = 'no_wait';

	    if($client_command =~ /(料金|価格|値段|単価)/){
		$next_state = 'state_02';
		$mode = 'no_wait';
	    }elsif($client_command =~ /(性能|速さ|速度|容量)/){
		$next_state = 'state_03';
		$mode = 'no_wait';
	    }elsif($client_command =~ /(こんにちは|こんばんは|お疲れ様)/){
		$next_state = 'state_04';
		$mode = 'no_wait';
	    }else{
		$next_state = 'failed_go_init';
		$mode = 'no_wait';
		$client_data->{last_failed_message} = $client_command;
	    }
	    return($next_state,$mode,$response,$client_data);
	},
	state_02 => sub {
	    my $client_id = shift;
	    my $client_data = shift;
	    my $client_command = shift;
	    my $response = "エントリーモデルの標準価格は100,000円となっております。<br>\nエンタープライズモデルでは標準価格400,000円です。";
	    my $next_state = 'init_state';
	    my $mode = 'no_wait';
	    return($next_state,$mode,$response,$client_data);
	},
	state_03 => sub {
	    my $client_id = shift;
	    my $client_data = shift;
	    my $client_command = shift;
	    my $response = "エントリーモデルですと、CPUは1ソケット4コア、メモリは16GBとなります。<br>また、エンタープライズモデルはCPUが2ソケットでそれぞれ6コア、メモリは32GB搭載しています。\n";
	    my $next_state = 'init_state';
	    my $mode = 'no_wait';
	    return($next_state,$mode,$response,$client_data);
	},
	state_04 => sub {
	    my $client_id = shift;
	    my $client_data = shift;
	    my $client_command = shift;
	    my $response = "あ、どうも。よろしくお願いします。";
	    my $next_state = 'init_state';
	    my $mode = 'no_wait';
	    return($next_state,$mode,$response,$client_data);
	},

	failed_go_init => sub {
	    my $client_id = shift;
	    my $client_data = shift;
	    my $client_command = shift;
	    my $last_failed_command = encode_entities($client_data->{last_failed_message},q{&<>"'});
	    my $response = "質問の意図が理解できませんでした。<br> 「 $last_failed_command 」";
	    my $next_state = 'init_state';
	    my $mode = 'no_wait';
	    return($next_state,$mode,$response,$client_data);
	}
       };
    return($scenario);
}

1;
