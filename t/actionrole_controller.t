use strict;
use warnings;
use Test::More;
use Test::Exception;

if (!eval { require Catalyst::Controller::ActionRole; Catalyst::Controller::ActionRole->VERSION(0.11); }) {
    plan skip_all => 'Catalyst::Controller::ActionRole not found';
    exit 0;
}

plan tests => 1;

lives_ok {
    require ActionRoleController;
} 'Can load controller which inherits from ActionRole and applys roles with method attributes';

