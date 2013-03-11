package WebApp::Auth;

use strict;
use warnings;
use MIME::Lite;
use base 'WebApp::Controller';
use utf8;

sub bridge {
	my $self = shift;
	my @stack = @{$self->match->stack};
	shift @stack;
	shift @stack;
	unless ( @stack ){
		$self->render_not_found;
		return 0;
	}
	return 1 if $stack[0]->{controller} eq 'auth' && $stack[0]->{action} =~ /login|logout/; 
	foreach( @stack ){
		unless( $self->app->schema->resultset( 'Page' )->search( { action => $_->{action}, controller=> $_->{controller}})->all()){
			$self->render_not_found ;
			return 0;
		}
		unless( $self->app->schema->resultset( 'Page' )->search( 
			{ -and => {
				-or => {
					-and => {
						'roles.user_id' => $self->session->{user_id},
						'roles.id'	=> {'!=', undef},
					},
					'grp.id'        => 0
				},
				'me.action'     => $_->{action}, 
			  	'me.controller' => $_->{controller}
			  }
			}, 
			{ join => { 'acls' => {'grp' => 'roles' }}} 
		)->all()){
			if( $self->session->{user_id} && $self->app->schema->resultset( 'Grp' )->search( { is_tp => 1, 'roles.user_id' => $self->session->{user_id}},{join => "roles"} )->first && $self->app->schema->resultset( 'Page' )->search( {'grp.is_tp' => 1, 'me.action'     => $_->{action}, 'me.controller' => $_->{controller}}, {join => {acls => 'grp'}} )->first){
				$self->render( {template => "main/change_tp", error => 'Not access for this tp'});
			}
			else {
				$self->render( template => "auth/login", error => 'Need auth', back_url => $self->param('back_url')||'/'.$_->{controller}.'/'.$_->{action}.'/'.$_->{id} );
			}
			return 0;
		}
	}
	return 1;
}

# This action will render a template

sub login {
	my $self = shift;
	if( $self->isPOST ){
		return $self->render({ error => 'No valid login, pass' }) if $self->user_auth( $self->param('login'), $self->param('password'));
		$self->redirect_back();
	}
	return $self->render();
}

sub logout {
    my $self = shift;
	$self->session( 'user_id', undef);
	$self->app->schema->resultset( 'Basket' )->search( session_id => $self->session->{id} )->delete;
	$self->session( 'id', undef);
	$self->redirect_to('/');
}

sub register {
	my $self = shift;
	if( $self->isPOST && $self->param('email')){
		my $ret = $self->add_user($self->param('email'));
		delete $ret->{new_user};
		if( $self->param('ajax')){
			return $self->render_json( $ret );
		}
		else{
			if( $ret->{status} eq 'Ok' ){
				$self->session( 'MESSAGE', 'Вы успешно зарегестрированы. Вам на почту отправленно письмо!' );
				return $self->redirect_back();
			}
			else {
				return $self->render( $ret->{mtype} => $ret->{text} );
			}
		}
	}
	return $self->render();
}

sub activationlink {
	my $self = shift;
	if( $self->stash->{id} && $self->param('email') ){
        my $usr = $self->app->schema->resultset( 'User' )->find({ 'email' => lc($self->param('email')), 'activationid' => $self->stash->{id} });
        return $self->render() unless $usr;
        $self->session('user_id', $usr->id);
		$usr->update({ activationid => undef });
		return $self->redirect_to( '/user' );
	}
	return $self->render();
}

sub lostpassword {
	my $self = shift;
	if( $self->isPOST && $self->param('email')){
		my $usr = $self->app->schema->resultset( 'User' )->find({ 'email' => lc($self->param('email'))});
		unless( $usr ){
			$self->session( 'ERROR', 'Такой пользователь не существует!' );
		}
		else {
			$usr->update({ activationid => Data::UUID->new->create_str() });
			$self->stash->{activationid} = $usr->activationid;
			$self->stash->{email} = $usr->email;
			$self->send_mail({to => $self->param('email'), template => 'mail/lostpassword.html.tt'});
			$self->session( 'MESSAGE', 'Вам на почту выслано письмо с дальнейшими инструкциями.' );
		}
		return $self->redirect_back();
	}
	return $self->render();
}

1;
