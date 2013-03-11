package WebApp::Main;

use strict;
use warnings;

use base 'WebApp::Controller';

# This action will render a template
sub welcome {
    my $self = shift;
    my @collection = $self->app->schema->resultset('Collection')->search({status => 'active'}, {page => int(rand(200)+1) ,rows => 1})->all();
    my @diagnostic = $self->app->schema->resultset('Diagnostic')->search({status => 'active'}, {page => int(rand(6)+1) ,rows => 1})->all();
    my @articles   = $self->app->schema->resultset('Article')->search({ visible => 't' },{ order_by => "random()", rows => 2})->all();
    my $articles_news   = $self->app->schema->resultset('Article')->search({ categories => 'news', visible => 't', public_date => DateTime->now->set_time_zone( 'Europe/Moscow' )});
	my $rows = 2;
	$rows = 1 if ( my $a_news = $articles_news->first );
    my @articles   = $self->app->schema->resultset('Article')->search({ categories => {'!=' => 'news'}, visible => 't' },{ order_by => "random()", rows => $rows })->all();
	push @articles, $a_news;
    my @panels     = $self->app->schema->resultset('Panel')->search({ revolver => 't' }, {rows => 7})->all();
    my $panels_cnt = $self->app->schema->resultset('Panel')->count;
    my $unit_cnt   = $self->app->schema->resultset('Unit')->search({status => {'!=' => 'deleted'}})->count;
    my @pop_lab    = $self->app->schema->resultset('Network')->search( {rating => {"is not",undef}},{order_by => { -desc => "rating"}, rows => 8})->all();
    my @pop_unit	   = $self->app->schema->resultset('OrderBasket')->search(
        {},
        {
	  	  rows => 8, 
          'select' => [ { count => 'collection_id', -as => 'cnt' }, 'collection_id' ],
          order_by => { -desc => 'cnt' },
          group_by => 'collection_id'
        })->all();
    $self->render(collection => [@collection], diagnostic => [@diagnostic], article => [@articles], panel => [@panels], cnt => $panels_cnt, ucnt => $unit_cnt, pop_lab => [@pop_lab], pop_unit => [@pop_unit] );
}

sub review {
	my $self = shift;
	my @qrating = $self->app->schema->resultset('RatingQuestion')->search(undef, {order_by => "sort"})->all();
	my @comment = $self->app->schema->resultset('RatingComment')->search({ moderated => 1 },{order_by => "date", rows => 4 })->all();
	$self->render( qrating => [@qrating], comment => [@comment] );
}

sub lab_owner {
	my $self = shift;
	return $self->render( tps => [$self->app->schema->resultset('Grp')->search({is_tp => 1})->all()] );
}

sub test {
	my $self = shift;
	return $self->render( layout => '' );
}

1;
