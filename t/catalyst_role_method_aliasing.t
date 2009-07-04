use strict;
use warnings;

{
    package Catalyst::Controller;
    use Moose;
    use namespace::clean -except => 'meta';
    use MooseX::MethodAttributes;
    BEGIN { extends 'MooseX::MethodAttributes::Inheritable'; }
}

{
    package ControllerRole;
    use Moose::Role -traits => 'MethodAttributes';
    use namespace::clean -except => 'meta';

    sub not_attributed : Local {} # This method should get composed as foo.
}
{
    package roles::Controller::Foo;
    use Moose;
    BEGIN { extends 'Catalyst::Controller'; }

    use Test::More tests => 1;
    use Test::Exception;
    throws_ok {
        with 'ControllerRole' => { alias => { not_attributed => 'foo' } };
    } qr/oes not currently support/;
    exit;

    sub not_attributed {}
}

