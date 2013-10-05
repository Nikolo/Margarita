package WebApp::Mmarket;
use strict;
use utf8;

sub install {
	my $self = shift;
	
	return $self->redirect_back();
}

sub uninstall {
	my $self = shift;
	return $self->redirect_back();
}

1;
