package TooClean;

use Moose;
use List::MoreUtils qw/uniq/;
use namespace::clean -except => 'meta';

use MooseX::MethodAttributes;

sub get_action_methods {
    return uniq(qw/ foo bar foo baz /);
}

1;

