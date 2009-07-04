package Other::Role;
use Moose::Role;

package ClassUsingCombinationRoleWithAttributes;
use Moose;

use namespace::clean -except => 'meta';

with qw/
    RoleWithAttributes
    Other::Role
/;

__PACKAGE__->meta->make_immutable;

