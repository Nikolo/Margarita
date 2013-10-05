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
		$self->app->schema->resultset('User')->find({ id => $self->session->{user_id} })->update({ last_visit => DateTime->now->set_time_zone( 'Europe/Moscow' ) }) if $self->stash->{user}->last_visit || $yday != $self->stash->{user}->last_visit->day_of_year;
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
