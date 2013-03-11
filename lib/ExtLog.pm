package ExtLog;
use Mojo::Base 'Mojo::EventEmitter';

use strict;
use base 'Mojo::Log';
use Carp 'croak';
use Fcntl ':flock';
use utf8;

has user => "default";

sub new {
  	my $self = shift->SUPER::new(@_);
  	$self->on(message => \&_message);
  	return $self;
}

sub log { 
	shift->emit('message', lc(shift), @_); 
}

sub _message {
	my ($self, $level, @lines) = @_;
 	return unless $self->is_level($level) && (my $handle = $self->handle);
  	flock $handle, LOCK_EX;
  	croak "Can't write to log: $!"
  	unless defined $handle->syswrite($self->format($level, @lines));
  	flock $handle, LOCK_UN;
}

sub format {
  	my ($self, $level, @lines) = @_;
	my $user = $self->user;
	my $i = 0;
	while( my @call = caller(++$i) ){
#		push @lines, "\t".join " ", @call[0..3];
	}
 	return '[' . localtime(time) . "] [$level] " . " " . "[$user]" . " " . join("\n",@lines) . "\n";
}

1;
