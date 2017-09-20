package MyChat;
use strict;
use warnings;

sub new {
    my $class = shift;
    my $self = {
	client_id_list => {},
	client_data => {},
	current_scenario => undef,
	current_state => undef
       };
    bless $self, $class;
    return $self;
}

sub create_client_id {
    my $self = shift;
    my $suffix = time();
    my @rand_list = (0 .. 9, 'A' .. 'Z', 'a' .. 'z');
    my $client_id = $suffix.'_';
    for(1 .. 32){
	$client_id .= $rand_list[int(rand($#rand_list + 1))];
    }
    return($client_id);
}

sub add_client_id {
    my $self = shift;
    my $client_id = shift;
    $self->{client_id_list}->{$client_id} = 1;
}

sub get_client_id {
    my $self = shift;
    my $client_id = shift;
    if(defined($self->{client_id_list}->{$client_id})){
	if($self->{client_id_list}->{$client_id} == 1){
	    return('online');
	}else{
	    return('revoked');
	}
    }else{
	return('empty');
    }
}

sub set_client_data {
    my $self = shift;
    my $client_id = shift;
    my $client_data = shift;
    $self->{client_data}->{$client_id} = $client_data;
}

sub get_client_data {
    my $self = shift;
    my $client_id = shift;
    my $client_data = $self->{client_data}->{$client_id};
    return($client_data);
}

sub set_current_scenario {
    my $self = shift;
    my $current_scenario = shift;
    $self->{current_scenario} = $current_scenario;
}

sub set_current_state {
    my $self = shift;
    my $client_id = shift;
    my $current_state = shift;
    $self->{current_state}->{$client_id} = $current_state;
}

sub input_client_command {
    my $self = shift;
    my $client_id = shift;
    my $client_command = shift;
    my $client_data = $self->{client_data}->{$client_id};
    push(@{$client_data->{command_history}},$client_command);
    my $current_scenario = $self->{current_scenario};
    my $current_state = $self->{current_state}->{$client_id};
    my ($next_state,$mode,$response,$new_client_data) = $current_scenario->{$current_state}->($client_id,$client_data,$client_command);
    $self->{client_data}->{$client_id} = $new_client_data;
    use Data::Dumper;
    print Dumper $client_data;
    return $next_state,$mode,$response;
}

1;
