package ActionRoleController;
use Moose;
use namespace::clean -except => 'meta';

BEGIN { extends 'Catalyst::Controller::ActionRole' }

with 'RoleWithAttributes';

__PACKAGE__->meta->make_immutable;

1;

