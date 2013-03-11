package WebApp::User;

use strict;
use warnings;
use utf8;
use base 'WebApp::Controller';
use DateTime;
use Data::UUID;

sub data {
	my $self = shift;
	my @stack = @{$self->match->stack};
	shift @stack;
	return $self->render_not_found unless @stack;
    $self->session('id',Data::UUID->new->create_hex()) if !$self->session->{id};
	$self->stash( 'user', $self->app->schema->resultset('User')->find( {id => $self->session->{user_id}} ));
	$self->app->log->user($self->stash->{user} ? $self->stash->{user}->email : $self->session('id'));
	foreach( qw(ERROR MESSAGE WARNING) ){
		next unless $self->session->{$_};
		$self->stash( $_, $self->session->{$_} );
		$self->session( $_, undef );
	}
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,undef) = localtime(time);
	if ( $self->stash->{user} && $self->stash->{user}->last_visit ) {
		$self->app->schema->resultset('User')->find({ id => $self->session->{user_id} })->update({ last_visit => DateTime->now->set_time_zone( 'Europe/Moscow' ) }) if ( $yday != $self->stash->{user}->last_visit->day_of_year)
	}
	if ( $self->stash->{user} && ! $self->stash->{user}->last_visit ) {
		$self->app->schema->resultset('User')->find({ id => $self->session->{user_id} })->update({ last_visit => DateTime->now->set_time_zone( 'Europe/Moscow' ) })
	}
	my $q = $self->{tx}->req->method . " " . $self->{tx}->req->url->base->scheme . "://" . $self->{tx}->req->url->base->host . "/" . join ("/", @{$self->{tx}->req->url->path->parts});
	$self->app->log->info($q);
	if( $self->isGET ){
		$self->stash->{pager_add_param} = $self->tx->req->params->to_string;
	}
	return 1;
}

# This action will render a template
sub history {
	my $self = shift;
	my $order = $self->app->schema->resultset('Order')->search( { 'user_id' => $self->session->{user_id}}, {order_by => {-desc => "date"}, rows => 10} )->page( $self->stash->{id}||1 );
	$self->render( order => [$order->all], pager => $order->pager(), in_basket => [$self->app->schema->resultset('Basket')->search({ session_id => $self->session->{id} })->all] );
}

sub set_address {
	my $self = shift;
	my $status = 'Error';
	if ( $self->isPOST ){
		$self->session('update_addr', time());
		my $q = $self->{tx}->req->method . " " . $self->{tx}->req->url->base->scheme . "://" . $self->{tx}->req->url->base->host . "/" . join ("/", @{$self->{tx}->req->url->path->parts}) . " Change coords from: " . $self->session('position') . "\n";
		$self->session('position', $self->param('position'));
		$self->session('addr', $self->param('addr'));
		$self->app->log->info($q);
		my ($lon,$lat) = split (' ',$self->session('position'));
		$self->stash('position_lon',$lon);
		$self->stash('position_lat',$lat);
		$self->stash('location',$self->param('addr'));
		$q = $self->{tx}->req->method . " " . $self->{tx}->req->url->base->scheme . "://" . $self->{tx}->req->url->base->host . "/" . join ("/", @{$self->{tx}->req->url->path->parts}) . " Change coords to: " . $self->session('position') . "\n";
		$self->app->log->info($q);
		$status = 'OK';
        my $ua = Mojo::UserAgent->new;
		$ua->request_timeout(1);
        my $ip_info = $ua->get('http://geo.serving-sys.com/GeoTargeting/ebGetLocation.aspx?ip=' . $self->req->headers->header('x-forwarded-for') )->res->body;  
        my $data = {map  { (split /=/, $_) } split(/&/, $ip_info)};
		
		foreach( $self->app->schema->resultset('Basket')->search({ session_id => $self->session->{id}, collection_id => {"is not",undef}  }, { order_by => 'collection_id' })->all ){
			$self->app->schema->resultset('Basket')->find( $_->id )->update({
				avg_price => $self->collection_price_for_region( $_->collection_id )->{avg_price},
				min_price => $self->collection_price_for_region( $_->collection_id )->{min_price},
				max_price => $self->collection_price_for_region( $_->collection_id )->{max_price},
				currency  => $self->collection_price_for_region( $_->collection_id )->{currency}
			});
		}
		foreach( $self->app->schema->resultset('Basket')->search({ session_id => $self->session->{id}, diagnostic_id => {"is not",undef}  }, { order_by => 'diagnostic_id' })->all ){
			$self->app->schema->resultset('Basket')->find( $_->id )->update({
				avg_price => $self->diagnostic_price_for_region( $_->diagnostic_id )->{avg_price},
				min_price => $self->diagnostic_price_for_region( $_->diagnostic_id )->{min_price},
				max_price => $self->diagnostic_price_for_region( $_->diagnostic_id )->{max_price},
				currency  => $self->diagnostic_price_for_region( $_->diagnostic_id )->{currency}
			});
		}
	}
	return $self->render_text( '{"Status":"'.$status.'"}' );
}

sub welcome {
	my $self = shift;
	if( $self->isPOST ) {
		my $user = $self->stash->{user};
		my $param = {map {$_ => $self->param( $_ )||undef} qw/sex birth_date code last_name first_name city country/};
		$param->{password} = \("crypt('".$self->param( 'pass' )."', gen_salt( 'bf', 12))") if $self->param( 'pass' );
		if ( $self->param('mailer') ) {
			$param->{not_receive_mailer} = 1
		} else {
			$param->{not_receive_mailer} = 0
		}
		if( $self->param( 'pass' ) && $self->param( 'pass' ) != $self->param( 're_pass' )){
			$self->session( 'ERROR', 'Не совпадают пароли' );
		}
		else {
			$self->session( 'MESSAGE', 'Данные успешно сохранены' );
			$user->update( $param );
		}
		return $self->redirect_back;
	}
	return $self->render();
}

1;
