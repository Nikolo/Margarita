package Template::Filter::Encode;

use base qw( Template::Plugin::Filter );
use Encode;
use strict;
use utf8;

sub filter {
	my $self = shift;
	my $text = shift;
#	my $args = shift;
	my $conf = $self->{ _CONFIG }||shift;
	my $meth = $conf->{method};
	
	if( $conf->{method} =~ /(?:en|de)code|from_to/ ){
		my $obj = Encode::find_encoding( $conf->{encoding} );
		die "Unknown encoding ".$conf->{encoding} unless $obj;
		return $obj->$meth( $text );
	}
	elsif( $conf->{method} =~ /_utf8_on/ ){
		Encode::_utf8_on( $text );
		return $text;
	}
	elsif( $conf->{method} =~ /_utf8_off/ ){
		Encode::_utf8_off( $text );
		return $text;
	}
	else {
		die "Unknown method ".$conf->{method};
	}
}

1;
