use strict;
use warnings;
use FindBin qw/ $Bin /;
use lib "$Bin/lib";

use Test::More;

require TooClean;
my @things = TooClean->get_action_methods;
is_deeply([ sort @things ], [sort qw/ foo bar baz /]);

done_testing;

