package WebApp::Article;

use strict;
use warnings;
use utf8;
use base 'WebApp::Controller';
use DateTime;
use Data::UUID;

sub _list {
	my $self = shift;
	my $atype = shift||$self->app->schema->resultset('ArticleGroup')->search({name => lc([caller(0)]->[4])})->first->id;
	my $articles_group = [$self->schema->resultset('ArticleGroup')->all()];
	my $articles_rs = $self->schema->resultset('Article')->search({article_group => $atype, rows => 10, page => $self->stash('page')||1});
	my $articles = [$articles_rs->all()];
	return $self->render( template => 'article/list', articles => $articles, article_groups => $articles_group, pager => $articles_rs->pager() );
}

sub hair { shift->_list() }
sub photo { shift->_list() }
sub makeup { shift->_list() }

1;

__END__

create table article_group (
	id serial primary key,
	name varchar(256)
);

create table articles (
	id serial primary key,
	name varchar(256),
	anounce varchar(2048),
	text text,
	create_date datetime,
	author int,
	article_group_id int,
	CONSTRAINT "ref_author" FOREIGN KEY (author) REFERENCES users(id),
	CONSTRAINT "ref_article_group_id" FOREIGN KEY (article_group_id) REFERENCES article_group(id)
);

