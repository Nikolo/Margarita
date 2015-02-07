package WebApp::Main;

use strict;
use warnings;
use File::Copy;
use File::stat;
use base 'WebApp::Controller';
use Encode;
use Cwd 'abs_path';
# This action will render a template

sub upload {
	my $self = shift;
	my $ret = {};
	if( $self->isPOST && $self->param('files.path') ){
		my $path_to_public = "$FindBin::Bin/../public";
		my $path_to_img = "/img/files/";
		unless( -d $path_to_public.$path_to_img ){
			mkdir $path_to_public.$path_to_img  or die "Mkdir failed: ".decode( 'utf8', $! );
		}
		$self->param('files.name') =~ /\.([^\.]+)$/;
		my $fname = time().'_'.$self->param('files.name');
		my $image_path = $path_to_img.$fname;
		copy($self->param('files.path'),$path_to_public.$image_path) or die "Copy failed: ".decode( 'utf8', $! );
		push @{$ret->{files}}, {name => $fname, url => $image_path};
	}
	return $self->render_json($ret);
}

sub files {
	my $self = shift;
	my $path_to_public = "$FindBin::Bin/../public";
	my $path_to_img = "/img/files/";
	my $ret = [];
	my $dirs_main = IO::Dir->new( $path_to_public.$path_to_img );
	foreach my $fname ( grep { $_ =~ /\.[^\.]+$/ } $dirs_main->read()){
		my $st = stat($path_to_public.$path_to_img.$fname);
		push @$ret, {name => decode('utf8',$fname), url => decode('utf8',$path_to_img.$fname), ctime => $st->ctime};
	}
	return $self->render(layout => 'admin', files => [ sort {$b->{ctime} <=> $a->{ctime}} @$ret]);
}

sub file_delete {
	my $self = shift;
	my $path_to_public = "$FindBin::Bin/../public";
	my $path_to_img = "/img/files/";
	my $abs_path_dir = abs_path($path_to_public.$path_to_img);
	if( $self->isPOST && -f $path_to_public.$path_to_img.$self->param('fname')){
		if( abs_path($path_to_public.$path_to_img.$self->param('fname')) =~ /^$abs_path_dir/ ){
			unlink( $path_to_public.$path_to_img.$self->param('fname') );
			return $self->render_json({status => 'ok'});
		}
		rturn $self->render_json({status => 'error'});
	}
	return $self->render_json({status => 'error'});
}

sub menu {
	my $self = shift;
	if( $self->isPOST ){
		my $iter = 0;
		foreach( split ',', $self->param('data')){
			$iter += 10;
			$self->app->schema->resultset('Menu')->find({id => $_ })->update({position => $iter});
		}
		return $self->render_json({status => "ok"});
	}
	
	return $self->render(items => [$self->app->schema->resultset('Menu')->search(undef,{order_by => ['menu_type_id','position']})->all()], layout => 'admin');
}

1;
