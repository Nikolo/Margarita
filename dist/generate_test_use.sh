count_use_test=`egrep -r "^use " ../ | awk '{print $2}' | sed 's/;//' | egrep -v 'base|strict|utf8|warnings|^lib$' | sort | uniq | wc -l`
echo "use strict;

use Test::More tests => $count_use_test;
use utf8;
use lib 'lib/';
" > ../t/use.t;
egrep -r "^use " ../ | awk '{print $2}' | sed 's/;//' | egrep -v 'base|strict|utf8|warnings|^lib$' | sort | uniq | awk '{print "use_ok( \""$1"\" );"}' >> ../t/use.t;
