use strict;
use warnings;
use JSON;
use Plack::MIME; # mimeタイプ自動判別用
use Data::Dumper;
use File::Slurp; # 効率的な静的ファイル応答
use Plack::Request;
use Plack::Session;
use MyChat;
use MyScenario;

# 静的ファイル置き場
my $public_dir = './public';

# ディレクトリインデックスの指定
my $index_files = ['index.html','index.htm','top.html'];

my $json = JSON->new->allow_nonref;

my $bot = MyChat->new();
$bot->set_current_scenario(MyScenario::load_scenario);

# psgiアプリ本体
my $app = sub {
    my $env = shift; # plackからの環境変数等が格納されたhashref
    my $req = Plack::Request->new($env);
    my $session = Plack::Session->new($env);
    # PATH_INFO毎に実行するサブルーチンを定義
    my $responses = {
        '/top' => sub {
            return [
                200,
                [ 'Content-Type' => 'text/plain' ],
                [ 'Welcome!' ]
               ];
        },
        '/get_client_id' => sub {
	    my $client_id = $bot->create_client_id();
	    if($bot->get_client_id($client_id) eq 'online'){
		$client_id = $bot->create_client_id();
	    }
	    $bot->add_client_id($client_id);
	    $bot->set_current_state($client_id,'init_state');
            return [
                200,
                [ 'Content-Type' => 'application/json' ],
                [ $json->encode({client_id => $client_id}) ]
               ];
        },
        '/kaiwa' => sub {
	    my $client_id = $req->parameters->{client_id};
	    my $id_validation = $bot->get_client_id($client_id);
	    if($id_validation eq 'online'){
		my $message = $req->parameters->{message};
		my ($next_state,$mode,$response) = $bot->input_client_command($client_id,$message);
		my $show_message = 1;
		if(!defined($response) or ($response eq '')){
		    $show_message = 0;
		}
		$bot->set_current_state($client_id,$next_state);
		return [
		    200,
		    [ 'Content-Type' => 'application/json' ],
		    [ $json->encode(
			{
			    flag => 1,
			    show_message => $show_message,
			    response => $response,
			    mode => $mode
			   }
		       )
		     ]
		   ];
	    }else{
		return [
		    200,
		    [ 'Content-Type' => 'application/json' ],
		    [ $json->encode(
			{
			    flag => 0,
			    show_message => 1,
			    response => '<font color="DD0000">[error] クライアントの特定に失敗しました。botを初期化して下さい。</font>',
			    mode => 'wait'
			   }
		       )
		     ]
		   ];
	    }
        },
    };

    # 404 Not Foundレスポンス
    my $not_found = [
        404,
        ['Content-Type' => 'text/plain'],
        ['404 Not found']
       ];
    # mime type
    my $mime = 'application/octet-stream'; # 不明時のデフォルト
    if($env->{PATH_INFO} =~ /(\.[^\.]+?)$/i){
        my $extension = $1;
        $mime = Plack::MIME->mime_type($extension);
    }

    # PATH_INFOから処理を振り分け
    if(defined($responses->{$env->{PATH_INFO}})){
        # $responsesに定義済みの場合に実行
        return $responses->{$env->{PATH_INFO}}->();
    }elsif(-f $public_dir.$env->{PATH_INFO}){
        # 静的ファイルが存在する場合に実行
        return [
            200,
            ['Content-Type' => $mime],
            [read_file($public_dir.$env->{PATH_INFO})],
           ];
    }else{
        # ファイル指定されていない場合はディレクトリインデックスをサーチ
        foreach my $index_file (@$index_files){
            if(-f $public_dir.$env->{PATH_INFO}.$index_file){
                if($index_file =~ /(\.[^\.]+?)$/i){
                    my $extension = $1;
                    $mime = Plack::MIME->mime_type($extension);
                }
                return [
                    200,
                    ['Content-Type' => $mime],
                    [read_file($public_dir.$env->{PATH_INFO}.$index_file)],
                   ];
            }
        }
        # 最終的に見つからなかった場合は 404 Not Found
        return $not_found;
    }
};


return $app;
