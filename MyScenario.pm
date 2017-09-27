package MyScenario;
use strict;
use warnings;
use HTML::Entities;

sub load_scenario {

    my $scenario = {
	# 初期状態
	init_state => sub {
	    my $client_id = shift;
	    my $client_data = shift;
	    my $client_command = shift;
	    return('state_01','wait',"こちらはフェイクサーバー株式会社のおしゃべりボットです！<br>\nサーバーなどを販売しております！何か質問して下さいませ！\n",$client_data);
	},
	# 初期状態から入力を受け取ったあとの分岐用
	state_01 => sub {
	    my $client_id = shift;
	    my $client_data = shift;
	    my $client_command = shift;
	    my $client_command_res = encode_entities($client_command,q{&<>"'});
	    my $response = "";
	    my $next_state = 'final_state';
	    my $mode = 'no_wait';

	    if($client_command =~ /(商品|ラインナップ|サーバ|料金|価格|値段|単価)/){
		$next_state = 'state_02';
		$mode = 'no_wait';
	    }elsif($client_command =~ /(性能|速さ|速度|容量)/){
		$next_state = 'state_03';
		$mode = 'no_wait';
	    }elsif($client_command =~ /(おはよう|こんにちは|こんばんは|お疲れ様|乙|おっす|オッス|やあ|よう)/){
		$next_state = 'state_04';
		$mode = 'no_wait';
	    }elsif($client_command =~ /(遊ぼう|(何|なに)かやって|(あなた|君|お前|おまえ|)(は|)(誰|だれ)(だ|\?|？))/){
		$client_data->{easter_egg_command} = $client_command;
		$next_state = 'state_easter_egg';
		$mode = 'no_wait';
	    }else{
		$next_state = 'failed_go_init';
		$mode = 'no_wait';
		$client_data->{last_failed_message} = $client_command;
	    }
	    return($next_state,$mode,$response,$client_data);
	},
	# 商品ラインナップの説明を求められた時
	state_02 => sub {
	    my $client_id = shift;
	    my $client_data = shift;
	    my $client_command = shift;
	    my $response = "エントリーモデルの標準価格は100,000円となっております。<br>\nエンタープライズモデルでは標準価格400,000円です。<br>\n購入をご希望ですか？（はい、いいえ）";
	    my $next_state = 'state_buy_01';
	    my $mode = 'wait';
	    return($next_state,$mode,$response,$client_data);
	},
	# 商品のスペックについての説明を求められた時
	state_03 => sub {
	    my $client_id = shift;
	    my $client_data = shift;
	    my $client_command = shift;
	    my $response = "エントリーモデルですと、CPUは1ソケット4コア、メモリは16GBとなります。<br>また、エンタープライズモデルはCPUが2ソケットでそれぞれ6コア、メモリは32GB搭載しています。\n";
	    my $next_state = 'init_state';
	    my $mode = 'no_wait';
	    return($next_state,$mode,$response,$client_data);
	},
	# あいさつされた時
	state_04 => sub {
	    my $client_id = shift;
	    my $client_data = shift;
	    my $client_command = shift;
	    my $response = "あ、どうも。よろしくお願いします。";
	    my $next_state = 'init_state';
	    my $mode = 'no_wait';
	    return($next_state,$mode,$response,$client_data);
	},
	# 購入ステップ1
	state_buy_01 => sub {
	    my $client_id = shift;
	    my $client_data = shift;
	    my $client_command = shift;
	    my $response;
	    my $next_state = 'init_state';
	    my $mode = 'wait';

	    if($client_command =~ /(はい|ハイ|yes)/){
		$response = "ご購入を検討頂きありがとうございます。<br>\n「エントリーモデル」、「エンタープライズモデル」のどちらを購入しますか？\n";
		$next_state = 'state_buy_02';
		$mode = 'wait';
	    }elsif($client_command =~ /(いいえ|イイエ|いらない|no)/){
		$response = "それは残念です。欲しくなったらまたお声掛けくださいね。\n";
		$next_state = 'init_state';
		$mode = 'no_wait';
	    }else{
		$response = "投稿内容が理解できませんでした。<br>\nもう一度お願いします<br>\n";
		$next_state = 'state_02';
		$mode = 'no_wait';
	    }
	    return($next_state,$mode,$response,$client_data);
	},
	# 購入ステップ2
	state_buy_02 => sub {
	    my $client_id = shift;
	    my $client_data = shift;
	    my $client_command = shift;
	    my $response;
	    my $next_state = 'init_state';
	    my $mode = 'wait';

	    if($client_command =~ /(エントリー|安い方|安いの|安い(やつ|ヤツ))/){
		$response = "エントリーモデルの購入をご希望ですね。料金は100,000円になりますが、よろしいでしょうか？（はい、いいえ）\n";
		$next_state = 'state_buy_03';
		$mode = 'wait';
		$client_data->{buy_target} = 'エントリーモデル';
	    }elsif($client_command =~ /(エンタープライズ|高い方|高いの|一番良い(やつ|ヤツ))/){
		$response = "エンタープライズモデルの購入をご希望ですね。料金は400,000円になりますが、よろしいでしょうか？（はい、いいえ）\n";
		$next_state = 'state_buy_03';
		$mode = 'wait';
		$client_data->{buy_target} = 'エンタープライズモデル';
	    }else{
		$response = "投稿内容が理解できませんでした。<br>\nもう一度お願いします<br>\n「エントリーモデル」、「エンタープライズモデル」のどちらを購入しますか？\n";
		$next_state = 'state_buy_02';
		$mode = 'wait';
	    }
	    return($next_state,$mode,$response,$client_data);
	},
	# 購入ステップ3（最終）
	state_buy_03 => sub {
	    my $client_id = shift;
	    my $client_data = shift;
	    my $client_command = shift;
	    my $buy_target = $client_data->{buy_target};
	    my $response = "";
	    my $next_state = 'init_state';
	    my $mode = 'wait';

	    if($client_command =~ /(はい|ハイ|yes)/){
		$response = "<font size=\"5\">$buy_target をご購入頂き誠にありがとうございます！<br>\n今後ともよろしくお願いします！<br></font>\n\n";
		$next_state = 'init_state';
		$mode = 'no_wait';
		delete $client_data->{buy_target};
	    }elsif($client_command =~ /(いいえ|イイエ|いらない|no)/){
		$response = "うーん、残念です。欲しくなったらまたお声掛けくださいね。\n";
		$next_state = 'init_state';
		$mode = 'no_wait';
		delete $client_data->{buy_target};
	    }else{
		$response = "投稿内容が理解できませんでした。<br>\nもう一度お願いします<br>\n$buy_target を購入しますか？（はい、いいえ）\n";
		$next_state = 'state_buy_03';
		$mode = 'wait';
	    }
	    return($next_state,$mode,$response,$client_data);
	},
	# イースターエッグ状態
	state_easter_egg => sub {
	    my $client_id = shift;
	    my $client_data = shift;
	    my $client_command = shift;
	    my $prev_client_command = $client_data->{easter_egg_command};
	    my $response = "";
	    my $next_state = 'init_state';
	    my $mode = 'no_wait';

	    if($prev_client_command =~ /(あなた|君|お前|おまえ|)(は|)(誰|だれ)(だ|\?|？)/){
		$response = "吾輩はボットである。名前はまだ無い。\n";
	    }else{
		$response = "うーん、今度時間がある時に！\n";
	    }
	    delete $client_data->{easter_egg_command};
	    return($next_state,$mode,$response,$client_data);
	},
	# 質問の意図が理解できなかった時
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
