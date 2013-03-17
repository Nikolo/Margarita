package WebApp::Page;

use strict;
use warnings;
use IO::Dir;
use base 'WebApp::Controller';

sub list {
	my $self = shift;
    my @units = $self->app->schema->resultset('Page')->search({},{order_by => 'controller, action'})->all();
    my @grps = $self->app->schema->resultset('Grp')->all();
    $self->render(layout => 'admin', units => [@units], grps => [@grps]);
}

sub edit {
    my $self = shift;
    my $unit = $self->app->schema->resultset('Page')->find( { id => $self->stash->{id} });
	my $grp = [$self->app->schema->resultset('Grp')->all()];
	my $mtype = [$self->app->schema->resultset('MenuType')->all()];
    if( $self->isPOST ){
        my %param = map {$_ => $self->param( $_ )} qw/title/;
        $unit->update( \%param );
		$unit->add_to_grps( id => $self->param('add_grp') ) if $self->param('add_grp') =~ /^\d+$/;
		$unit->add_to_menus({ menu_type_id => $self->param('add_menu'), name => $self->param('menu_name') }) if $self->param('add_menu') =~ /^\d+$/;
		return $self->redirect_back;
    }
    else {
        $self->render( page => $unit, grps => $grp, menu_types => $mtype, layout => 'admin' );
    }
}

sub upload {
	my $self = shift;
	return $self->redirect_to('/') if !$self->stash->{id};
	my $page = $self->app->schema->resultset('Page')->find({ id => $self->stash->{id} });
	return $self->redirect_to('/') if !$page;
	if( $self->isPOST ){
		if ( my $path = $self->param( "img.path" ) ) {
			if ( ( File::Type->checktype_filename($path) =~ /image\/png/ ) && ( image_info($path)->{width} != 90 ) && ( image_info($path)->{height} != 90 ) ) {
				$self->upload_file({
					type        => 'pages',
					name        => $self->param( "img.name"),
					keyword     => 'admin_image',
					path        => $path,
					filename    => $page->{controller}.$page->{action}.".png",
					delete_prev => 1,
				});
			}
			else {
				$self->session('ERROR', 'Загружаемый файл или не является png изображением или размер не 90х90');
			}
		}
	}
	return $self->redirect_back();
}

sub menu_delete {
	my $self = shift;
	if( $self->stash->{id} && defined($self->param('menu_id'))){
		$self->app->schema->resultset('Menu')->find({ page_id => $self->stash->{id}, id => $self->param('menu_id') })->delete();
	}
	return $self->redirect_back();
}

1;
