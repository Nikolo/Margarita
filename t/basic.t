use Mojo::Base -strict;

BEGIN {
  $ENV{MOJO_MODE}    = 'development';
  $ENV{MOJO_NO_IPV6} = 1;  
  $ENV{MOJO_REACTOR} = 'Mojo::Reactor::Poll';
}

use Test::More tests => 61;
use Test::Mojo;
use utf8;
use lib 'lib/';

use FindBin;
$ENV{MOJO_HOME} = "$FindBin::Bin/../";

require "$ENV{MOJO_HOME}/lib/WebApp.pm";
import WebApp;

my $t = Test::Mojo->new("WebApp");
$t->get_ok('/');


__END__
$t->get_ok('/')->status_is(200)->header_is(Server => 'Mojolicious (Perl)')->header_is('X-Powered-By' => 'Mojolicious (Perl)')->content_like(qr/Анализмаркет/i);
$t->get_ok('/about/')->status_is(200)->header_is(Server => 'Mojolicious (Perl)')->header_is('X-Powered-By' => 'Mojolicious (Perl)')->content_like(qr/Анализмаркет/i);
$t->get_ok('/tests/')->status_is(200)->header_is(Server => 'Mojolicious (Perl)')->header_is('X-Powered-By' => 'Mojolicious (Perl)')->content_like(qr/Анализмаркет/i);
$t->get_ok('/labs/')->status_is(200)->header_is(Server => 'Mojolicious (Perl)')->header_is('X-Powered-By' => 'Mojolicious (Perl)')->content_like(qr/Анализмаркет/i);
$t->get_ok('/privacy/')->status_is(200)->header_is(Server => 'Mojolicious (Perl)')->header_is('X-Powered-By' => 'Mojolicious (Perl)')->content_like(qr/Анализмаркет/i);
$t->get_ok('/cart/')->status_is(200)->header_is(Server => 'Mojolicious (Perl)')->header_is('X-Powered-By' => 'Mojolicious (Perl)')->content_like(qr/Анализмаркет/i);
$t->get_ok('/panels/')->status_is(200)->header_is(Server => 'Mojolicious (Perl)')->header_is('X-Powered-By' => 'Mojolicious (Perl)')->content_like(qr/Анализмаркет/i);
$t->get_ok('/tests/all')->status_is(200)->header_is(Server => 'Mojolicious (Perl)')->header_is('X-Powered-By' => 'Mojolicious (Perl)')->content_like(qr/Анализмаркет/i);

#$t->get_ok('/order/id/')->status_is(302)->header_is(Server => 'Mojolicious (Perl)')->header_is('X-Powered-By' => 'Mojolicious (Perl)')->content_like(qr/Анализмаркет/i);
$t->get_ok('/panels/id/')->status_is(302)->header_is(Server => 'Mojolicious (Perl)')->header_is('X-Powered-By' => 'Mojolicious (Perl)')->content_like(qr/Анализмаркет/i);
$t->get_ok('/tests/id/')->status_is(302)->header_is(Server => 'Mojolicious (Perl)')->header_is('X-Powered-By' => 'Mojolicious (Perl)');

# GET /favicon.ico (bundled file in DATA section)
$t->get_ok('/favicon.ico')->status_is(200);

# GET public/work/logo.png
# (random static requests)
$t->get_ok('/work/logo.png')->status_is(200);
$t->get_ok('/article/test.jpg')->status_is(200);
$t->get_ok('/img/logo.gif')->status_is(200);

$t->post_form_ok('/auth/login', {__login => 'login', __passwd => 'password'})
    ->status_is(200)
    ->content_type_is("text/html;charset=UTF-8")
    ->content_like(qr/Анализмаркет/i);

=here
sub _panels {
        my $self = shift;
		my $pp = 1;
        use Data::Dumper;
        die Dumper $pp;
}
$t->_panels;
# GET /auto_name
=here
get '/rating' => sub {
  my $self = shift;
  $self->render(text => $self->url_for('rating'));
}
# GET /auto_name
$t->get_ok('/rating')->status_is(200)
  ->header_is(Server         => 'Mojolicious (Perl)')
  ->header_is('X-Powered-By' => 'Mojolicious (Perl)')
  ->content_is('/rating');
=cut
