package TooClean;

use Moose;
use List::MoreUtils qw/uniq/;
use namespace::clean -except => 'meta';

use TooCleanMethodAttributes;

sub get_action_methods {
    return uniq(qw/ foo bar foo baz /);
}

1;

