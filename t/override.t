use strict;
use warnings;
use Test::More tests => 2;

use FindBin;
use lib "$FindBin::Bin/lib";

use SubClassWithOverride;

is_deeply(
    SubClassWithOverride->meta->get_method('foo')->attributes,
    [q{SomeAttribute}, q{AnotherAttribute('with argument')}],
);

is_deeply(
    SubClassWithOverride->meta->get_method('bar')->attributes,
    [q{SomeAttribute}],
);
