package WebApp::Grp;

use strict;
use warnings;
use utf8;
use base 'WebApp::Controller';

sub list {
	my $self = shift;
	return $self->render( layout => 'admin', grps => [$self->app->schema->resultset('Grp')->all()]);
}

sub edit {
    my $self = shift;
    my $grp = $self->app->schema->resultset('Grp')->find( { id => $self->stash->{id} });
    if( $self->isPOST ){
        my %param = map {$_ => $self->param( $_ ) || undef} qw/name description/;
		$param{is_tp} = $self->param( 'is_tp' )||'0';
		$param{enable_active_link} = $self->param( 'enable_active_link' )||'0';
		$param{num_units} = $self->param( 'num_units' )||'0';
		$grp->update( \%param );
		if( $self->param( 'email' )){
			if( my $usr = $self->app->schema->resultset('User')->search({email => lc($self->param( 'email' ))})->first ){
				$usr->add_to_grps( id => $grp->id );
			}
			else {
				$self->session( 'ERROR', 'Пользователь с таким email не найден в БД' );
			}
		}
		if( $self->param( 'add_page' )){
			$self->app->schema->resultset('Page')->find( $self->param( 'add_page' ))->add_to_grps( id => $grp->id ); 
		}
        return $self->redirect_back( );
    }
    else {
        $self->render( layout => 'admin', grp => $grp, pages => [$self->app->schema->resultset('Page')->search(undef, {order_by => ['controller', 'action']})->all()], usr => [$self->app->schema->resultset('Role')->search({ grp_id => $self->stash->{id} })->all()]);
    }
}

sub create {
    my $self = shift;
    $self->app->schema->resultset('Grp')->create( {name => $self->param( 'name' )} );
    return $self->redirect_back();
}

sub delete {
    my $self = shift;
    if( $self->param( 'page_id' )){
	$self->app->schema->resultset('Acl')->search({ page_id => $self->param( 'page_id' ), grp_id => $self->stash->{id} })->delete;
    }
    elsif($self->param( 'user_id' )) {
	$self->app->schema->resultset('Role')->search({ user_id => $self->param( 'user_id' ), grp_id => $self->stash->{id} })->delete;
    }
    return $self->redirect_back;
}

1;
