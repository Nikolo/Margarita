package WebApp;

use Mojo::Base 'Mojolicious';
use Mojo::Base 'Mojolicious::Plugin';
use Mojolicious::Plugin::TtRenderer;
use Schema;
use FindBin;
use Config::JSON;
use ExtLog;
use Cache::Memcached::Fast;
use Storable;
use IO::Dir;

has schema => sub {
	my $self = shift;
	my $schema = Schema->connect('dbi:Pg:dbname='.$self->config->{db}->{name}.';host='.$self->config->{db}->{host}, $self->config->{db}->{user}, $self->config->{db}->{pass}, {pg_enable_utf8 => 1 } );
	return $schema;
};

has memcache => sub {
	my $self = shift;
	return unless $self->config->{memcache};
	return Cache::Memcached::Fast->new({
		servers => [ $self->config->{memcache}->{host}.":".$self->config->{memcache}->{port} ],
		namespace => 'margarita:',
		connect_timeout => 0.2,
		io_timeout => 0.5,
		close_on_error => 1,
		max_failures => 3,
		failure_timeout => 2,
		nowait => 1,
		serialize_methods => [ \&Storable::freeze, \&Storable::thaw ],
		utf8 => 1,
		max_size => $self->config->{memcache}->{val_max_size}||1024,
	});
};

has log => sub {
	my $self = shift;
	return ExtLog->new( path => $self->config->{log_path}||$FindBin::Bin.'/../log/', level => $self->config->{log_level}||'warn')
};

has mtt => sub {
	my $self = shift;
	return Template->new( %{$self->tt_param()} );
};

sub tt_param {
	my $self = shift;
	return {
		INCLUDE_PATH => $self->config->{template}->{INCLUDE_PATH}||$FindBin::Bin.'/../templates/',
		COMPILE_DIR  => $self->config->{template}->{COMPILE_DIR}||'/tmp/margarita_tt',
		COMPILE_EXT  => $self->config->{template}->{COMPILE_EXT}||'.ttc',
		ENCODING     => $self->config->{template}->{ENCODING}||'utf8',
	}
}

# This method will run once at server start
sub startup {
	my $self = shift;
	$self->config(%{Config::JSON->new( $FindBin::Bin.'/../margarita.cfg' )->{config}});
	$self->secret( $self->config->{secret} );
	$self->plugin(tt_renderer => { template_options => $self->tt_param() });
	$self->renderer->default_handler('tt');
	$self->mode( $self->config->{app_mode}||'production' );
	my $path_to_template = $self->config->{template}->{INCLUDE_PATH}||$FindBin::Bin.'/../templates/';
	my $path_to_public = $path_to_template.'/../public/';	
	my $max_t = {js => 0, css => 0};
	foreach my $ftype ( keys %$max_t ){
		my $dirs = IO::Dir->new( $path_to_public.$ftype.'/' );
		foreach my $files ( grep { $_ =~ /\.$ftype$/ && -f $path_to_public.$ftype.'/'.$_ } $dirs->read()){
			$max_t->{$ftype} = (stat( $path_to_public.$ftype.'/'.$files))[9] if $max_t->{$ftype} < (stat( $path_to_public.$ftype.'/'.$files))[9];
		}
	}
	my $ret = {};
	foreach ($self->schema->resultset('Page')->search(undef, {order_by => "controller"})->all()){
		next if -f $path_to_template.'/'.$_->controller.'/'.$_->action.'.html.tt';
		$ret->{$_->controller}->{$_->action} = 1;
	}
	foreach my $coll (keys %$ret){
		my $pm = $path_to_template.'/../lib/WebApp/'.ucfirst($coll).'.pm';
		next unless -f $pm;
		my $FH;
		open( $FH, "<", $pm );
		while( <$FH> ){
			next unless /sub\s+([^_].*?)(?:\s*{|$)/;
			delete $ret->{$coll}->{$1} if exists $ret->{$coll}->{$1};
		}
		close( $FH );
	}
	foreach my $coll (keys %$ret){
		foreach my $act (%{$ret->{$coll}}){
			foreach ($self->app->schema->resultset('Page')->search( {controller => $coll, action => $act||''} )->all()){
				$_->acls->delete();
				$_->delete();
			}
		}
	}
	my $dirs_main = IO::Dir->new( $path_to_template );
	if( $dirs_main ){
		foreach my $dir_main ( grep {$_ !~ /^\./ && -d $path_to_template.$_ } $dirs_main->read() ){
			my $files = IO::Dir->new( $path_to_template.'/'.$dir_main );
			foreach ( grep { -f $path_to_template.'/'.$dir_main.'/'.$_ } $files->read()){
				s/\..*?\..*?$//;
				next unless $_;
				next if $dir_main =~ /layouts|\.mail/;
				$self->app->schema->resultset('Page')->new({controller => $dir_main, action => $_})->insert() unless $self->app->schema->resultset('Page')->find({controller => $dir_main, action => $_});
			}
		}
	}
	$dirs_main = IO::Dir->new( $path_to_template.'/../lib/WebApp/' );
	foreach my $pms ( grep { $_ =~ /\.pm$/ && -f $path_to_template.'/../lib/WebApp/'.$_ } $dirs_main->read()){
		my $FH;
		open( $FH, "<", $path_to_template.'/../lib/WebApp/'.$pms);
		$pms = lc($pms);
		$pms =~ s/\.pm$//;
		my $need_list = 0;
		while( <$FH> ){
			$need_list = 1 if /^use base.*WebApp::Controller/;
			next if $pms =~ /layouts|\.mail/;
			$self->app->schema->resultset('Page')->new({controller => $pms, action => $1})->insert() if $need_list && /sub\s+([^_].*?)(?:\s*{|$)/ && !$self->app->schema->resultset('Page')->find({controller => $pms, action => $1});
		}
		close( $FH );
	}

	$self->helper( mtime_static => sub { $max_t });
	$self->sessions->default_expiration( 60 * 60 * 24 * 3 );
	$self->helper( word_ending => sub {
		my $self = shift;
		my $numeral = shift;
		die( "4 params are required " ) unless scalar( @_ ) == 3;
		return $_[$numeral == 1 ? 0 : $numeral > 1 && $numeral < 5 ? 1 : 2];
	});
	$self->helper( crumbs => sub {
		my $self = shift;
		my $crumbs = [{name => $self->app->schema->resultset( 'Page' )->search({ controller => 'main', action => 'welcome' })->first->title, link => '/'}];
		if( $self->stash('action') ne 'welcome' && (my $name = $self->app->schema->resultset( 'Page' )->search({ controller => $self->stash('controller'), action => 'welcome'})->first) ){
			push @$crumbs, {name => $name->title, link => '/'.$self->stash('controller')};
		}
		if( my $name = $self->app->schema->resultset( 'Page' )->search({ action => $self->stash('action'), controller => $self->stash('controller')})->first->title ){
			push @$crumbs, {name => $name, link => '/'.$self->stash('controller').'/'.$self->stash('action')};
		}
		return $crumbs; 
	});
	$self->helper( object_count => sub{
		my $self = shift;
		my $obj = shift;
		return !$obj 
			? undef
			: ref $obj ne 'ARRAY'
				? ref( $obj ) =~ /Schema::Result/
					? 1
					: undef 
				: scalar( @$obj );
	});
	$self->helper( layout_var => sub {
		my $self = shift;
		my $var = shift;
		my $val = shift;
		my $layout_var = $self->stash( 'layout_var' );
		if( defined $val ){
			$layout_var->{$var} = $val;
			$self->stash( 'layout_var', $layout_var );
			return ;
		}
		else {
			die "Layout var '".$var."' not set!" unless exists $layout_var->{$var};
			return $layout_var->{$var};
		}
	});
	$self->helper( menu_items => sub{
		my $self = shift;
		my $type = shift;
		my $controller = shift;
		my $ret = [$self->app->schema->resultset('Menu')->search(
			{
				'-or' => [
					"roles.user_id" => $self->session->{user_id},
					"grp.id" => 0,
				],
				'menu_type.name' => $type,
				$controller ? ("page.controller" => $controller ) : ()
			},
			{
				join => [ 'menu_type', {page => {acls => {grp => 'roles'}}}], 
				group_by => "me.id", 
				order_by => [qw/position/]
			}
		)->all()];
		return $ret;
	});
	$self->helper( get_facebook_data => sub {
		my $self = shift;
		return JSON::XS->new->utf8->decode(Mojo::UserAgent->new->get('https://graph.facebook.com/'.$self->config->{site}->{facebook_username})->res->body);
	});
	$self->helper( get_twitter_data => sub {
		my $self = shift;
		return JSON::XS->new->utf8->decode(Mojo::UserAgent->new->get('https://api.twitter.com/1/users/show.json?screen_name='.$self->config->{site}->{twitter_username})->res->body);
	});
	$self->helper( config_site => sub {	shift->config->{site} });
	$self->helper( exist_layout_var => sub {
		my $self = shift;
		my $var = shift;
		return exists $self->stash( 'layout_var' )->{$var};
	});
	$self->helper( image_for_object => sub {
        my $self = shift;
		my $obj_name = shift;
		my $obj_id = shift;
		my $keyword = shift;
		my $res = [];
		return [$self->app->schema->resultset('Upload')->search(
				{
					obj_name => $obj_name, 
					obj_id => $obj_id, 
					$keyword ? (tmpl_keyword => $keyword) : () 
				}, 
				{
					order_by => { -desc => "name"}
				} 
			)->all];
	});
	$self->hook(after_static_dispatch => sub {
		my $tx = shift;
		$tx->res->headers->remove('Set-Cookie');
	});
	$self->defaults(layout => 'user_default');

	# Router
	my $r = $self->routes;

	# Normal route to controller
	my $bridget = $r
		->bridge->to( controller => 'user', action => 'data' )
		->bridge->to( controller => 'auth', action => 'bridge' )
	;
	$bridget->route( '/:controller/:action/:id/page/:page' )->to( controller => 'main', action => 'welcome', id => 0, page => 0);
	$bridget->route( '/:controller/:action/:id' )->to( controller => 'main', action => 'welcome', id => 0 );
}

1;
